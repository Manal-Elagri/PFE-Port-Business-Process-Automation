package Projet_Stage.PFE.service;

import Projet_Stage.PFE.dto.*;
import com.lowagie.text.*;
import com.lowagie.text.Font;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.*;
import com.lowagie.text.Image;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.awt.*;
import java.io.ByteArrayOutputStream;

@Service
@RequiredArgsConstructor
public class PdfService {

    private final SecurityService securityService;


    public byte[] generateOperationPdf(OperationDocumentDTO dto, String secureLink) {

        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            Document document = new Document(PageSize.A4, 36, 36, 36, 36);
            PdfWriter.getInstance(document, out);

            document.open();

            Font titleFont = new Font(Font.HELVETICA, 16, Font.BOLD);
            Font sectionFont = new Font(Font.HELVETICA, 12, Font.BOLD);
            Font normalFont = new Font(Font.HELVETICA, 10);

            // =========================
            // HEADER AVEC LOGO
            // =========================
            PdfPTable headerTable = new PdfPTable(2);
            headerTable.setWidthPercentage(100);
            headerTable.setWidths(new int[]{1, 3});

            // LOGO
            try {
                Image logo = Image.getInstance("src/main/resources/static/logo_marsa.jpg");
                logo.scaleToFit(70, 70);

                PdfPCell logoCell = new PdfPCell(logo);
                logoCell.setBorder(Rectangle.NO_BORDER);
                headerTable.addCell(logoCell);
            } catch (Exception e) {
                PdfPCell empty = new PdfPCell();
                empty.setBorder(Rectangle.NO_BORDER);
                headerTable.addCell(empty);
            }

            // TEXTE
            PdfPCell textCell = new PdfPCell();
            textCell.setBorder(Rectangle.NO_BORDER);

            Paragraph headerText = new Paragraph();
            headerText.add(new Chunk("PORT DE CASABLANCA\n", titleFont));
            headerText.add(new Chunk("Direction d’Exploitation au Port de Casablanca\n", normalFont));
            headerText.add(new Chunk("Trafic Conteneur & Roulier\n", normalFont));

            textCell.addElement(headerText);
            headerTable.addCell(textCell);

            document.add(headerTable);
            document.add(new Paragraph(" "));

            // =========================
            // TITRE
            // =========================
            Paragraph title = new Paragraph("RAPPORT D'OPERATION", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);

            document.add(new Paragraph(" "));

            // =========================
            // INFOS OPERATION (SANS TABLE ✅)
            // =========================
            document.add(new Paragraph("INFORMATIONS GENERALES", sectionFont));
            document.add(new Paragraph(" "));


            document.add(new Paragraph("Type : " + dto.getType(), normalFont));
            document.add(new Paragraph("Statut : " + dto.getStatut(), normalFont));
            document.add(new Paragraph("Navire : " + dto.getEscale(), normalFont));
            document.add(new Paragraph("Shift : " + dto.getShift(), normalFont));
            document.add(new Paragraph("Poste : " + dto.getPoste(), normalFont));
            document.add(new Paragraph("Portier : " + dto.getPortier(), normalFont));
            document.add(new Paragraph("Equipe : " + dto.getEquipe(), normalFont));

            document.add(new Paragraph(" "));

            // =========================
            // ENGINS TABLE
            // =========================
            document.add(new Paragraph("ENGINS", sectionFont));

            PdfPTable enginTable = new PdfPTable(3);
            enginTable.setWidthPercentage(100);

            addCell(enginTable, "ID", true);
            addCell(enginTable, "Type", true);
            addCell(enginTable, "Capacité", true);

            for (EnginDTO e : dto.getEngins()) {
                addCell(enginTable, String.valueOf(e.getId()), false);
                addCell(enginTable, e.getType(), false);
                addCell(enginTable, String.valueOf(e.getCapacite()), false);
            }

            document.add(enginTable);
            document.add(new Paragraph(" "));

            // =========================
            // ARRETS TABLE
            // =========================
            document.add(new Paragraph("ARRETS", sectionFont));

            PdfPTable arretTable = new PdfPTable(4);
            arretTable.setWidthPercentage(100);

            addCell(arretTable, "Type", true);
            addCell(arretTable, "Début", true);
            addCell(arretTable, "Fin", true);
            addCell(arretTable, "Cause", true);

            for (ArretDTO a : dto.getArrets()) {
                addCell(arretTable, a.getType(), false);
                addCell(arretTable, String.valueOf(a.getDateDebut()), false);
                addCell(arretTable, String.valueOf(a.getDateFin()), false);
                addCell(arretTable, a.getCause(), false);
            }

            document.add(arretTable);
            document.add(new Paragraph(" "));

            // =========================
            // CONTENEURS TABLE
            // =========================
            document.add(new Paragraph("CONTENEURS", sectionFont));

            PdfPTable contTable = new PdfPTable(2);
            contTable.setWidthPercentage(100);

            addCell(contTable, "Matricule", true);
            addCell(contTable, "Type ISO", true);

            for (ConteneurDTO c : dto.getConteneurs()) {
                addCell(contTable, c.getMatricule(), false);
                addCell(contTable, c.getTypeIso(), false);
            }

            document.add(contTable);

            Paragraph total = new Paragraph(
                    "Total conteneurs : " + dto.getNombreConteneurs(),
                    sectionFont
            );
            total.setAlignment(Element.ALIGN_RIGHT);
            document.add(total);

            document.add(new Paragraph(" "));

            // =========================
            // SIGNATURES (amélioré léger)
            // =========================
            document.add(new Paragraph("SIGNATURES", sectionFont));

            PdfPTable signTable = new PdfPTable(3);
            signTable.setWidthPercentage(100);
            signTable.setWidths(new int[]{3, 2, 2});

            addCell(signTable, "Chef", true);
            addCell(signTable, "Fonction", true);
            addCell(signTable, "Signature", true);

            for (ChefSignatureDTO chef : dto.getChefs()) {

                PdfPCell nameCell = new PdfPCell(new Phrase(chef.getNomComplet()));
                nameCell.setPadding(10);
                signTable.addCell(nameCell);

                PdfPCell roleCell = new PdfPCell(new Phrase(chef.getRole()));
                roleCell.setPadding(10);
                signTable.addCell(roleCell);

                PdfPCell signatureCell = new PdfPCell(new Phrase(""));
                signatureCell.setPadding(10);
                signatureCell.setMinimumHeight(45);
                signTable.addCell(signatureCell);
            }

            document.add(signTable);

            // =========================
            // QR CODE DOCUMENT
            // =========================
            //String link = "https://mon-app.com/document/" + dto.getId();
            if (secureLink != null && !secureLink.isBlank()) {

                byte[] qrBytes = securityService.generateQrCode(secureLink);

                Image qrImage = Image.getInstance(qrBytes);
                qrImage.scaleToFit(120, 120);
                qrImage.setAlignment(Element.ALIGN_RIGHT);

                document.add(new Paragraph("Scanner pour accéder au document", sectionFont));
                document.add(qrImage);
            }
            /////////////////////////////////////

            document.close();

            return out.toByteArray();

        } catch (Exception e) {
            throw new RuntimeException("Erreur PDF", e);
        }
    }

    private void addCell(PdfPTable table, String text, boolean isHeader) {
        Font font = isHeader
                ? new Font(Font.HELVETICA, 10, Font.BOLD)
                : new Font(Font.HELVETICA, 10);

        PdfPCell cell = new PdfPCell(new Phrase(text != null ? text : "", font));
        cell.setPadding(5);

        if (isHeader) {
            cell.setBackgroundColor(new Color(220, 220, 220));
        }

        table.addCell(cell);
    }


      // =========================
     // AJOUTER SIGNATURE SUR PDF EXISTANT
    // =========================
    public byte[] addSignatureToExistingPdf(
            String existingPdfPath,
            String signatureImagePath,
            int x,
            int y
    ) {

        try {

            ByteArrayOutputStream out = new ByteArrayOutputStream();

            PdfReader reader = new PdfReader(existingPdfPath);

            PdfStamper stamper = new PdfStamper(reader, out);

            // première page
            PdfContentByte content =
                    stamper.getOverContent(1);

            // image signature
            Image signatureImage =
                    Image.getInstance(signatureImagePath);

            signatureImage.scaleToFit(100, 50);

            // position dans PDF
            signatureImage.setAbsolutePosition(x, y);

            content.addImage(signatureImage);

            stamper.close();
            reader.close();

            return out.toByteArray();

        } catch (Exception e) {
            throw new RuntimeException("Erreur ajout signature PDF", e);
        }
    }
}
