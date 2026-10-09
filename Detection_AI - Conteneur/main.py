from fastapi import FastAPI, UploadFile, File
import cv2
import numpy as np
import easyocr
import re
from ultralytics import YOLO
import uvicorn

app = FastAPI(title="Micro-service Detection Conteneur PFE")


def _build_letter_table():
    table, val = {}, 10
    for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
        while val in (11, 22, 33):
            val += 1
        table[c] = val
        val += 1
    return table


LETTER_VALUES = _build_letter_table()


def calculate_check_digit(owner, category, serial):
    full_code = owner + category + serial
    weights = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512]

    total = sum(
        (int(c) if c.isdigit() else LETTER_VALUES[c.upper()]) * weights[i]
        for i, c in enumerate(full_code)
    )

    remainder = total % 11
    return "0" if remainder == 10 else str(remainder)


reader = easyocr.Reader(["en"], gpu=False)
model = YOLO("best.pt")

print("MODEL CLASSES:", model.names)

DIGIT_FIXES = {
    "O": "0",
    "Q": "0",
    "D": "0",
    "I": "1",
    "L": "1",
    "S": "5",
    "B": "8",
    "G": "6",
}

LETTER_FIXES = {
    "0": "O",
    "1": "I",
    "5": "S",
    "8": "B",
    "6": "G",
    "2": "Z",
}


def smart_fix(text, is_matricule=True):
    text = re.sub(r"[^A-Za-z0-9]", "", text.upper())
    result = ""

    for i, c in enumerate(text):
        if is_matricule:
            if i < 4:
                result += LETTER_FIXES.get(c, c)
            else:
                result += DIGIT_FIXES.get(c, c)
        else:
            result += c

    return result


def extract_matricule_candidate(raw_text):
    cleaned = re.sub(r"[^A-Z0-9]", "", raw_text.upper())

    # Exemple fréquent OCR:
    # TCLUL22G1123415617 -> owner TCL_U + type ISO 22G1 + numero
    owner_matches = list(re.finditer(r"[A-Z0-9]{3}[UJZ]", cleaned))

    for owner_match in owner_matches:
        owner = smart_fix(owner_match.group(0), is_matricule=True)

        after = cleaned[owner_match.end():]

        # Enlever type ISO placé entre le code propriétaire et le numéro
        after = re.sub(r"^\d{2}[A-Z]\d", "", after)

        digits = "".join(DIGIT_FIXES.get(c, c) for c in after)
        digits = re.sub(r"\D", "", digits)

        if len(owner) == 4 and len(digits) >= 7:
            return owner + digits[:7]

    # Fallback: chercher directement une fenêtre de 11 caractères
    for i in range(0, max(0, len(cleaned) - 10)):
        chunk = cleaned[i:i + 11]
        fixed = smart_fix(chunk, is_matricule=True)

        if re.match(r"^[A-Z]{4}\d{7}$", fixed):
            return fixed

    return None


def is_valid_container_code(code):
    if not code or not re.match(r"^[A-Z]{4}\d{7}$", code):
        return False, None

    owner = code[:3]
    category = code[3]
    serial = code[4:10]
    check = code[10]

    expected = calculate_check_digit(owner, category, serial)
    return expected == check, expected


def ocr_variants(image):
    variants = []

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    scale = cv2.resize(
        gray,
        None,
        fx=2,
        fy=2,
        interpolation=cv2.INTER_CUBIC,
    )
    variants.append(scale)

    blur = cv2.GaussianBlur(scale, (3, 3), 0)
    variants.append(blur)

    _, threshold = cv2.threshold(
        scale,
        0,
        255,
        cv2.THRESH_BINARY + cv2.THRESH_OTSU,
    )
    variants.append(threshold)

    results = []

    for variant in variants:
        texts = reader.readtext(
            variant,
            detail=0,
            allowlist="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        )
        results.extend(texts)

    return results


def update_response_with_matricule(response, candidate, score):
    if not candidate:
        return

    valid, expected_digit = is_valid_container_code(candidate)

    response["matricule"] = candidate
    response["is_valid"] = valid
    response["expected_check_digit"] = expected_digit

    if valid:
        response["score"] = max(response["score"], score)
    else:
        response["score"] = max(response["score"], min(score, 0.50))


def update_response_with_type_iso(response, text):
    match_type = re.search(r"\d{2}[A-Z]\d", text.upper())

    if match_type:
        response["type_iso"] = match_type.group(0)
        response["typeIso"] = match_type.group(0)


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    contents = await file.read()
    nparr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    response = {
        "matricule": "NON_DETECTE",
        "type_iso": "NON_DETECTE",
        "typeIso": "NON_DETECTE",
        "score": 0.0,
        "is_valid": False,
        "expected_check_digit": None,
    }

    results = model.predict(img, conf=0.10, imgsz=960)[0]

    for box in results.boxes:
        x1, y1, x2, y2 = map(int, box.xyxy[0])
        label = results.names[int(box.cls[0])]
        conf = float(box.conf[0])

        print("DETECTED:", label, conf)

        crop = img[
            max(0, y1 - 8):min(img.shape[0], y2 + 8),
            max(0, x1 - 8):min(img.shape[1], x2 + 8),
        ]

        if crop.size == 0:
            continue

        if crop.shape[0] > crop.shape[1] * 1.2:
            crop = cv2.rotate(crop, cv2.ROTATE_90_CLOCKWISE)

        text_raw = "".join(ocr_variants(crop)).upper()

        print("YOLO LABEL:", label)
        print("OCR RAW:", text_raw)

        if label == "matricule":
            candidate = extract_matricule_candidate(text_raw)
            update_response_with_matricule(response, candidate, conf)

        elif label == "type_iso":
            update_response_with_type_iso(response, text_raw)

    global_ocr = reader.readtext(
        img,
        detail=0,
        allowlist="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
    )

    global_text = " ".join(global_ocr).upper()
    print("GLOBAL OCR:", global_text)

    if response["typeIso"] == "NON_DETECTE":
        update_response_with_type_iso(response, global_text)

    if response["matricule"] == "NON_DETECTE":
        candidate = extract_matricule_candidate(global_text)
        update_response_with_matricule(response, candidate, 0.70)

    type_ok = response["typeIso"] != "NON_DETECTE" and len(response["typeIso"]) == 4

    if not response["is_valid"] or not type_ok:
        response["score"] = min(response["score"], 0.50)

    print("FINAL RESPONSE:", response)

    return response


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)