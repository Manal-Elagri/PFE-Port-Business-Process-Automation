(function () {
  "use strict";

  if (typeof marked !== "undefined") {
    marked.setOptions({ breaks: true, gfm: true });
  }

  const apiKeyEl = document.getElementById("api-key");
  const jwtEl = document.getElementById("jwt-token");
  const toastEl = document.getElementById("toast");
  const sectionTitle = document.getElementById("section-title");
  const SECTION_TITLES = {
    chat: "Chat IA",
    whatsapp: "Mon Bot WhatsApp",
    knowledge: "Base de Connaissances",
    stats: "Statistiques",
  };

  function getApiKey() {
    return (
      window.FLUTTER_API_KEY ||
      localStorage.getItem("service_api_key") ||
      document.getElementById("api-key")?.value?.trim() ||
      ""
    );
  }
  
  function getJwtToken() {
    return (
      jwtEl?.value?.trim() ||
      localStorage.getItem("jwt_token") ||
      ""
    );
  }

  function persistJwtToken() {
    const token = getJwtToken();
    if (token) localStorage.setItem("jwt_token", token);
  }

  function apiHeaders() {
    const key = getApiKey();
    const jwtToken = getJwtToken();
    return {
      "X-API-Key": key,
      ...(jwtToken ? { Authorization: `Bearer ${jwtToken}` } : {}),
    };
  }

  function escapeHtml(text) {
    return String(text)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function formatBytes(n) {
    if (n < 1024) return `${n} o`;
    if (n < 1024 * 1024) return `${(n / 1024).toFixed(1)} Ko`;
    return `${(n / (1024 * 1024)).toFixed(1)} Mo`;
  }

  function formatDocDate(iso) {
    try {
      return new Date(iso).toLocaleString("fr-FR");
    } catch {
      return iso;
    }
  }

  function persistApiKey() {
    const key = getApiKey();
  
    if (!key) return; // ❗ ne jamais écraser
  
    localStorage.setItem("service_api_key", key);
    apiKeyEl.classList.remove("ring-red-500/60");
  }

  function ensureApiKey() {
    if (getApiKey()) return true;
    showToast("Saisissez votre clé API en haut à droite (valeur de SERVICE_API_KEY dans .env).", true);
    apiKeyEl.focus();
    persistApiKey();
    return false;
  }

  function showToast(msg, isError) {
    toastEl.textContent = msg;
    toastEl.style.background = isError ? "#ef4444" : "#10b981";
    toastEl.hidden = false;
    setTimeout(() => { toastEl.hidden = true; }, 5000);
  }

  async function apiFetch(url, options = {}) {
    if (!ensureApiKey()) throw new Error("Clé API manquante");
    const headers = { ...apiHeaders(), ...(options.headers || {}) };
    const res = await fetch(url, { ...options, headers });
    if (!res.ok) {
      let message = `Erreur ${res.status}`;
      try {
        const data = await res.json();
        message = data.error?.message || data.detail || message;
      } catch (_) { /* ignore */ }
      if (res.status === 401) {
        const low = (message || "").toLowerCase();
        if (low.includes("jwt") || low.includes("bearer") || low.includes("sub")) {
          message =
            "JWT invalide ou manquant — laissez vide pour le dashboard local, ou collez le token Java.";
        } else {
          message = "Clé API invalide — elle doit correspondre à SERVICE_API_KEY dans votre fichier .env";
        }
      }
      throw new Error(message);
    }
    return res;
  }

  function showSection(name) {
    document.querySelectorAll("[data-panel]").forEach((p) => {
      p.classList.add("hidden");
      p.classList.remove("flex");
    });
    const panel = document.getElementById(`panel-${name}`);
    if (panel) {
      panel.classList.remove("hidden");
      if (name === "chat") panel.classList.add("flex");
    }
    document.querySelectorAll("[data-nav]").forEach((n) => {
      n.classList.toggle("bg-zinc-800", n.dataset.nav === name);
    });
    if (sectionTitle) sectionTitle.textContent = SECTION_TITLES[name] || name;
    if (name === "knowledge") {
      loadMode();
      loadDocuments();
    }
    if (name === "stats") loadStats();
    if (name === "whatsapp") {
      loadWhatsAppStatus();
      showWhatsAppContactQr();
    }
    if (typeof lucide !== "undefined") lucide.createIcons();
  }

  function initRouter() {
    document.querySelectorAll("[data-nav]").forEach((btn) => {
      btn.addEventListener("click", () => showSection(btn.dataset.nav));
    });
    const savedKey = localStorage.getItem("service_api_key");
    if (apiKeyEl) {
      if (savedKey) apiKeyEl.value = savedKey;
      apiKeyEl.addEventListener("input", persistApiKey);
      apiKeyEl.addEventListener("change", persistApiKey);
      persistApiKey();
    }
    const savedJwt = localStorage.getItem("jwt_token");
    if (savedJwt && jwtEl) jwtEl.value = savedJwt;
    jwtEl?.addEventListener("input", persistJwtToken);
    jwtEl?.addEventListener("change", persistJwtToken);
    if (!getApiKey()) {
      showToast("Entrez la clé API (SERVICE_API_KEY du fichier .env) pour utiliser le dashboard.", true);
    }
    showSection("chat");
    loadMode();
  }

  function initChatSection() {
    const providerSelect = document.getElementById("provider-select");
    const modelGroup = document.getElementById("model-group");
    const modelSelect = document.getElementById("model");
    const contentTextarea = document.getElementById("content");
    const contentFileInput = document.getElementById("content-file");
    const mediaPreview = document.getElementById("media-preview-container");
    const previewContent = document.getElementById("preview-content");
    const btnRemoveMedia = document.getElementById("btn-remove-media");
    const themeToggle = document.getElementById("theme-toggle");
    const submitBtn = document.getElementById("submit");
    const chatMessages = document.getElementById("chat-messages");
    const sidebarToggle = document.getElementById("sidebar-toggle");
    const chatSettings = document.querySelector(".chat-settings");

    async function typewriterEffect(element, text) {
      element.innerHTML = "";
      let i = 0;
      return new Promise((resolve) => {
        const interval = setInterval(() => {
          element.innerHTML = marked.parse(text.substring(0, i + 1));
          i++;
          if (i >= text.length) {
            clearInterval(interval);
            resolve();
          }
          chatMessages.scrollTop = chatMessages.scrollHeight;
        }, 15);
      });
    }

    function appendMessage(role, content, isThinking = false) {
      document.getElementById("welcome")?.remove();
      const block = document.createElement("div");
      block.className = `msg-block ${role}`;
      const displayContent = isThinking
        ? '<div class="thinking"><span></span><span></span><span></span> Réflexion en cours...</div>'
        : (role === "user" ? content.replace(/\n/g, "<br>") : marked.parse(content));
      block.innerHTML = `
        <div class="msg-inner">
          <div class="msg-content-wrapper">
            <div class="msg-content">${displayContent}</div>
            <div class="msg-footer"></div>
          </div>
        </div>`;
      chatMessages.appendChild(block);
      chatMessages.scrollTop = chatMessages.scrollHeight;
      return block;
    }

    function addMetaData(block, data) {
      const footer = block.querySelector(".msg-footer");
      footer.innerHTML = `
        <div class="msg-meta-detail">
          <span class="meta-item">${data.model}</span>
          <span class="meta-item">In: ${data.usage.prompt_tokens} tk</span>
          <span class="meta-item">Out: ${data.usage.completion_tokens} tk</span>
          <span class="meta-item">${data.response_time_ms}ms</span>
          <span class="meta-item" style="color:var(--accent);font-weight:bold;">${data.cost_estimation || "$0.00 (free)"}</span>
        </div>`;
    }

    function checkSubmitState() {
      submitBtn.disabled = contentTextarea.value.trim() === "" && contentFileInput.files.length === 0;
    }

    async function loadOpenRouterModels() {
      modelSelect.innerHTML = "<option>Chargement...</option>";
      try {
        const res = await apiFetch("/v1/openrouter/models?free_only=true");
        const data = await res.json();
        modelSelect.innerHTML = data.models.map((m) => `<option value="${m.id}">${m.name}</option>`).join("");
      } catch (e) {
        modelSelect.innerHTML = "<option>Erreur</option>";
      }
    }

    async function submit() {
      const key = getApiKey();
      if (!key && providerSelect.value !== "ollama") {
        showToast("Veuillez saisir votre clé API.", true);
        return;
      }

      const provider = providerSelect.value;
      let model = modelSelect.value || null;
      if (!model) {
        if (provider === "llamacpp") model = "llamacpp";
        if (provider === "ollama") model = "qwen2.5:0.5b";
        if (provider === "gemini") model = "gemini-2.5-flash";
        if (provider === "groq") model = "llama-3.3-70b-versatile";
        if (provider === "openai") model = "gpt-4o-mini";
      }

      const userText = contentTextarea.value.trim();
      let content = userText;
      let inputType = "text";
      let mimeType = null;
      const file = contentFileInput.files[0];

      if (file) {
        if (file.type.startsWith("image/")) inputType = "image";
        else if (file.type.startsWith("video/")) inputType = "video";
        else if (file.type.startsWith("audio/")) inputType = "audio";
        content = await new Promise((resolve) => {
          const reader = new FileReader();
          reader.onload = () => resolve(reader.result.split(",")[1]);
          reader.readAsDataURL(file);
        });
        mimeType = file.type;
      }

      if (!content && !userText) return;

      appendMessage("user", userText || `[Fichier: ${file.name}]`);
      const assistantBlock = appendMessage("assistant", "", true);
      const assistantContentEl = assistantBlock.querySelector(".msg-content");

      contentTextarea.value = "";
      contentFileInput.value = "";
      mediaPreview.hidden = true;
      submitBtn.disabled = true;

      try {
        const res = await fetch("/v1/generate", {
          method: "POST",
          headers: { "Content-Type": "application/json", ...apiHeaders() },
          body: JSON.stringify({
            provider,
            model,
            input_type: inputType,
            content,
            user_prompt: inputType !== "text" ? userText : null,
            temperature: 0.7,
            max_tokens: 2048,
            content_mime_type: mimeType,
          }),
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error?.message || "Erreur serveur");
        await typewriterEffect(assistantContentEl, data.formatted_response);
        addMetaData(assistantBlock, data);
      } catch (e) {
        assistantContentEl.innerHTML = `<span style="color:#ef4444">Erreur: ${e.message}</span>`;
      } finally {
        checkSubmitState();
      }
    }

    themeToggle.addEventListener("click", () => {
      const isDark = document.documentElement.getAttribute("data-theme") === "dark";
      const next = isDark ? "light" : "dark";
      document.documentElement.setAttribute("data-theme", next);
      themeToggle.innerHTML = next === "dark" ? "🌙 Mode Sombre" : "☀️ Mode Clair";
    });

    document.getElementById("btn-media").onclick = () => {
      contentFileInput.accept = "image/*,video/*";
      contentFileInput.click();
    };
    document.getElementById("btn-audio").onclick = () => {
      contentFileInput.accept = "audio/*";
      contentFileInput.click();
    };

    contentFileInput.onchange = function () {
      const file = this.files[0];
      if (!file) return;
      mediaPreview.hidden = false;
      const reader = new FileReader();
      reader.onload = (e) => {
        if (file.type.startsWith("image/")) {
          previewContent.innerHTML = `<img src="${e.target.result}" style="width:100%;height:100%;object-fit:cover;">`;
        } else {
          previewContent.innerHTML = `<div style="display:flex;align-items:center;justify-content:center;height:100%;font-size:20px;">📄</div>`;
        }
      };
      reader.readAsDataURL(file);
      checkSubmitState();
    };

    btnRemoveMedia.onclick = () => {
      contentFileInput.value = "";
      mediaPreview.hidden = true;
      previewContent.innerHTML = "";
      checkSubmitState();
    };

    providerSelect.onchange = () => {
      const val = providerSelect.value;
      if (val === "openrouter") {
        modelGroup.hidden = false;
        loadOpenRouterModels();
      } else if (val === "ollama") {
        modelGroup.hidden = false;
        modelSelect.innerHTML = `
          <option value="qwen2.5:0.5b">Qwen 2.5 - 0.5B</option>
          <option value="deepseek-r1:1.5b">DeepSeek R1 - 1.5B</option>`;
      } else {
        modelGroup.hidden = true;
        modelSelect.innerHTML = "";
      }
    };

    submitBtn.onclick = submit;
    contentTextarea.oninput = checkSubmitState;
    if (sidebarToggle && chatSettings) {
      sidebarToggle.onclick = () => chatSettings.classList.toggle("open");
    }
    document.getElementById("btn-new-chat").onclick = () => {
      chatMessages.innerHTML = `
        <div class="welcome" id="welcome">
          <div class="logo text-4xl font-bold text-emerald-500 mb-2">AI</div>
          <h1>Comment puis-je vous aider ?</h1>
        </div>`;
      checkSubmitState();
    };
    contentTextarea.onkeydown = (e) => {
      if (e.key === "Enter" && !e.shiftKey && !submitBtn.disabled) {
        e.preventDefault();
        submit();
      }
    };
  }

  const WA_STATE_LABELS = {
    disconnected: "Déconnecté",
    connecting: "Connexion…",
    qr_pending: "QR serveur à scanner",
    connected: "Connecté — IA active",
    error: "Erreur",
  };

  let waPollTimer = null;
  let waConnected = false;

  function restartWaPoll() {
    if (waPollTimer) clearInterval(waPollTimer);
    waPollTimer = setInterval(() => {
      const panel = document.getElementById("panel-whatsapp");
      if (panel && !panel.classList.contains("hidden")) {
        loadWhatsAppStatus();
      }
    }, waConnected ? 45000 : 15000);
  }

  function isWaAdminMode() {
    return new URLSearchParams(window.location.search).get("admin") === "1";
  }

  function applyWaAdminVisibility(showAdmin) {
    const panel = document.getElementById("wa-admin-panel");
    if (!panel) return;
    if (showAdmin || isWaAdminMode()) {
      panel.classList.remove("hidden");
    } else {
      panel.classList.add("hidden");
    }
  }

  async function showWhatsAppContactQr() {
    const qrContainer = document.getElementById("qr-container");
    if (!qrContainer || !ensureApiKey()) return;
    qrContainer.innerHTML = `<p class="text-sm text-zinc-400">Chargement du QR…</p>`;
    try {
      const res = await apiFetch("/v1/whatsapp/qr?qr_type=contact");
      const blob = await res.blob();
      qrContainer.innerHTML = "";
      const img = document.createElement("img");
      img.src = URL.createObjectURL(blob);
      img.alt = "QR contact +212 689 461 643";
      img.className = "rounded-xl border border-zinc-700 max-w-[240px]";
      qrContainer.appendChild(img);
    } catch (e) {
      qrContainer.innerHTML = `<p class="text-sm text-red-400 px-4">${e.message}</p>`;
      showToast(e.message, true);
    }
  }

  async function showWhatsAppSetupQr() {
    const box = document.getElementById("qr-setup-container");
    if (!box || !ensureApiKey()) return;
    box.innerHTML = `<p class="text-sm text-zinc-400">Génération du QR serveur…</p>`;
    try {
      const res = await fetch("/v1/whatsapp/qr?qr_type=setup", { headers: apiHeaders() });
      if (res.status === 404) {
        box.innerHTML = `<p class="text-sm text-zinc-400">QR pas encore prêt — réessayez dans quelques secondes.</p>`;
        return;
      }
      if (!res.ok) throw new Error(`Erreur ${res.status}`);
      const blob = await res.blob();
      box.innerHTML = "";
      const img = document.createElement("img");
      img.src = URL.createObjectURL(blob);
      img.alt = "QR Neonize — liaison serveur";
      img.className = "rounded-xl border border-amber-600/50 max-w-[240px]";
      box.appendChild(img);
    } catch (e) {
      box.innerHTML = `<p class="text-sm text-red-400">${e.message}</p>`;
    }
  }

  async function connectWaNeonize() {
    if (!ensureApiKey()) return;
    try {
      const res = await apiFetch("/v1/whatsapp/connect", { method: "POST" });
      const data = await res.json();
      showToast("Connexion Neonize démarrée");
      await loadWhatsAppStatus();
      if (!data.connected && !data.session_saved) {
        setTimeout(showWhatsAppSetupQr, 800);
      }
    } catch (e) {
      showToast(e.message, true);
    }
  }

  async function resetWaSession() {
    if (!ensureApiKey()) return;
    try {
      await apiFetch("/v1/whatsapp/reset-session", { method: "POST" });
      showToast("Session reinitialisee — scannez le nouveau QR serveur");
      await loadWhatsAppStatus();
      setTimeout(showWhatsAppSetupQr, 1000);
    } catch (e) {
      showToast(e.message, true);
    }
  }

  async function loadWhatsAppStatus() {
    const ua = document.getElementById("wa-user-action");
    const adminSt = document.getElementById("wa-admin-status");
    const badge = document.getElementById("wa-connection-badge");
    if (!getApiKey()) return;
    try {
      const res = await apiFetch("/v1/whatsapp/status");
      const data = await res.json();
      if (ua && data.user_action) {
        ua.innerHTML = data.user_action.replace(/\n/g, "<br>");
      }
      if (adminSt) {
        let txt = data.display || "";
        if (data.session_saved && !data.connected) {
          txt += " — session enregistrée, pas de nouveau scan";
        }
        adminSt.textContent = txt;
        adminSt.className = data.connected
          ? "text-sm text-emerald-400"
          : "text-sm text-amber-300/90";
      }
      if (badge) {
        const state = data.connection_state || "disconnected";
        badge.textContent = WA_STATE_LABELS[state] || state;
        badge.className = `text-xs inline-block px-2 py-1 rounded ${
          data.connected ? "bg-emerald-900/50 text-emerald-300" : "bg-amber-900/40 text-amber-200"
        }`;
      }
      const wasConnected = waConnected;
      waConnected = !!data.connected;
      if (wasConnected !== waConnected) restartWaPoll();
      applyWaAdminVisibility(!!data.show_admin_panel);
      if (data.error) showToast(data.error, true);
    } catch (e) {
      if (adminSt) adminSt.textContent = e.message;
    }
  }

  function initWhatsAppSection() {
    applyWaAdminVisibility(isWaAdminMode());
    showWhatsAppContactQr();
    document.getElementById("btn-wa-connect")?.addEventListener("click", connectWaNeonize);
    document.getElementById("btn-qr-setup")?.addEventListener("click", showWhatsAppSetupQr);
    document.getElementById("btn-wa-reset")?.addEventListener("click", resetWaSession);

    restartWaPoll();
  }

  const MODE_LABELS = {
    web: "Mode actif : Recherche Web (réponses générales, sans vos documents).",
    docs: "Mode actif : Analyse de vos documents (RAG — réponses basées sur knowledge_base).",
  };

  function applyModeUi(mode) {
    document.querySelectorAll(".mode-btn").forEach((btn) => {
      const active = btn.dataset.mode === mode;
      btn.classList.toggle("bg-emerald-500", active);
      btn.classList.toggle("text-zinc-900", active);
      btn.classList.toggle("bg-zinc-800", !active);
      btn.classList.toggle("text-zinc-300", !active);
      btn.classList.toggle("hover:bg-zinc-700", !active);
    });
    const kbLabel = document.getElementById("kb-mode-label");
    if (kbLabel) {
      kbLabel.textContent = MODE_LABELS[mode] || "";
      kbLabel.className =
        mode === "docs"
          ? "text-sm text-emerald-400 mt-3 font-medium"
          : "text-sm text-zinc-400 mt-3";
    }
    const headerBadge = document.getElementById("header-mode-badge");
    if (headerBadge) {
      headerBadge.hidden = false;
      headerBadge.textContent = mode === "docs" ? "RAG documents" : "Mode web";
      headerBadge.className =
        mode === "docs"
          ? "text-xs px-2 py-1 rounded bg-emerald-900/50 text-emerald-300"
          : "text-xs px-2 py-1 rounded bg-zinc-800 text-zinc-400";
    }
  }

  async function loadMode() {
    if (!getApiKey()) return;
    try {
      const res = await apiFetch("/v1/mode");
      const data = await res.json();
      applyModeUi(data.mode || "web");
    } catch (e) {
      applyModeUi("web");
    }
  }

  async function setMode(mode) {
    if (!ensureApiKey()) return;
    try {
      const res = await apiFetch("/v1/mode", {
        method: "POST",
        headers: { "Content-Type": "application/json", ...apiHeaders() },
        body: JSON.stringify({ mode }),
      });
      const data = await res.json();
      applyModeUi(data.mode);
      showToast(
        mode === "docs"
          ? "Mode documents activé — uploadez des fichiers puis testez dans Chat IA."
          : "Mode web activé."
      );
    } catch (e) {
      showToast(e.message, true);
    }
  }

  async function loadDocuments() {
    const tbody = document.getElementById("files-table");
    if (!tbody) return;
    if (!getApiKey()) {
      tbody.innerHTML =
        '<tr><td colspan="3" class="px-4 py-6 text-center text-zinc-500">Saisissez la clé API en haut</td></tr>';
      return;
    }
    try {
      const res = await apiFetch("/v1/documents");
      const data = await res.json();
      const files = data.files || [];
      if (!files.length) {
        tbody.innerHTML =
          '<tr><td colspan="3" class="px-4 py-6 text-center text-zinc-500">Aucun fichier — uploadez un PDF, Word ou Excel</td></tr>';
        return;
      }
      tbody.innerHTML = files
        .map(
          (f) => `
        <tr class="hover:bg-zinc-800/40">
          <td class="px-4 py-3 text-zinc-200">${escapeHtml(f.name)}</td>
          <td class="px-4 py-3 text-zinc-400">${formatBytes(f.size_bytes)}</td>
          <td class="px-4 py-3 text-zinc-400">${formatDocDate(f.modified_at)}</td>
        </tr>`
        )
        .join("");
    } catch (e) {
      tbody.innerHTML = `<tr><td colspan="3" class="px-4 py-6 text-center text-red-400">${escapeHtml(e.message)}</td></tr>`;
    }
  }

  async function uploadFiles(fileList) {
    if (!fileList?.length || !ensureApiKey()) return;
    const form = new FormData();
    for (const file of fileList) form.append("files", file);
    try {
      const res = await fetch("/v1/upload", {
        method: "POST",
        headers: apiHeaders(),
        body: form,
      });
      if (!res.ok) {
        let message = `Erreur ${res.status}`;
        try {
          const data = await res.json();
          message = data.error?.message || data.detail || message;
        } catch (_) {
          /* ignore */
        }
        throw new Error(message);
      }
      const data = await res.json();
      showToast(`${data.count || fileList.length} fichier(s) ajouté(s) à la base`);
      await loadDocuments();
      const uploadInput = document.getElementById("upload-input");
      if (uploadInput) uploadInput.value = "";
    } catch (e) {
      showToast(e.message, true);
    }
  }

  function initKnowledgeSection() {
    const dropZone = document.getElementById("drop-zone");
    const uploadInput = document.getElementById("upload-input");

    document.getElementById("mode-web")?.addEventListener("click", () => setMode("web"));
    document.getElementById("mode-docs")?.addEventListener("click", () => setMode("docs"));

    if (dropZone && uploadInput) {
      dropZone.addEventListener("click", () => uploadInput.click());
      uploadInput.addEventListener("change", () => uploadFiles(uploadInput.files));
      dropZone.addEventListener("dragover", (e) => {
        e.preventDefault();
        dropZone.classList.add("border-emerald-500");
      });
      dropZone.addEventListener("dragleave", () => dropZone.classList.remove("border-emerald-500"));
      dropZone.addEventListener("drop", (e) => {
        e.preventDefault();
        dropZone.classList.remove("border-emerald-500");
        uploadFiles(e.dataTransfer.files);
      });
    }

    loadMode();
    loadDocuments();
  }

  function renderStatsMap(container, obj) {
    const entries = Object.entries(obj || {});
    if (!entries.length) {
      container.innerHTML = `<p class="text-zinc-500">Aucune donnée</p>`;
      return;
    }
    container.innerHTML = entries.map(([k, v]) => `
      <div class="flex justify-between py-1 border-b border-zinc-700/50">
        <span class="text-zinc-300 truncate mr-2">${k}</span>
        <span class="text-emerald-400 font-medium">${v}</span>
      </div>`).join("");
  }

  async function loadStats() {
    try {
      const res = await apiFetch("/metrics");
      const data = await res.json();
      document.getElementById("stat-requests").textContent = data.requests_total ?? 0;
      document.getElementById("stat-tokens").textContent = data.tokens_total ?? 0;
      renderStatsMap(document.getElementById("stats-by-provider"), data.by_provider);
      renderStatsMap(document.getElementById("stats-by-model"), data.by_model);
    } catch (e) {
      showToast(e.message, true);
    }
  }

  let statsInterval = null;
  function initStatsSection() {
    document.getElementById("btn-refresh-stats").addEventListener("click", loadStats);
    if (statsInterval) clearInterval(statsInterval);
    statsInterval = setInterval(() => {
      const panel = document.getElementById("panel-stats");
      if (panel && !panel.classList.contains("hidden")) loadStats();
    }, 30000);
  }

  function safeInit(name, fn) {
    try {
      fn();
    } catch (err) {
      console.error(`Init ${name} failed:`, err);
      showToast(`Erreur initialisation ${name} — voir la console (F12)`, true);
    }
  }

  safeInit("router", initRouter);
  safeInit("knowledge", initKnowledgeSection);
  safeInit("chat", initChatSection);
  safeInit("whatsapp", initWhatsAppSection);
  safeInit("stats", initStatsSection);
})();


