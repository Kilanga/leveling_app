const bindShopPreviewHandlers = () => {
  if (window.__shopPreviewBound) return;
  window.__shopPreviewBound = true;

  document.addEventListener("click", (event) => {
    const trigger = event.target.closest(".js-shop-preview-trigger");
    if (!trigger) return;

    event.preventDefault();

    const previewType = trigger.dataset.previewType;
    const previewName = trigger.dataset.previewName || "";
    const previewClass = trigger.dataset.previewClass || "";

    const frameElement = document.getElementById("shop-preview-frame");
    const frameNameElement = document.getElementById("shop-preview-frame-name");
    const xpTrackElement = document.getElementById("shop-preview-xp-track");
    const xpNameElement = document.getElementById("shop-preview-theme-name");
    const cardElement = document.getElementById("shop-preview-card");
    const cardTextElement = document.getElementById("shop-preview-card-text");
    const titleElement = document.getElementById("shop-preview-title");

    if (previewType === "profile_frame" && frameElement && frameNameElement) {
      frameElement.className = `profile-frame-container ${previewClass}`;
      frameNameElement.textContent = `Cadre apercu: ${previewName || "Aucun"}`;
    }

    if (previewType === "xp_theme" && xpTrackElement && xpNameElement) {
      xpTrackElement.className = `xp-track shop-impact-xp-track ${previewClass}`;
      xpNameElement.textContent = `Theme XP apercu: ${previewName || "Standard"}`;
    }

    if (previewType === "profile_card") {
      if (cardElement) {
        cardElement.className = `shop-preview-card profile-card-container ${previewClass} mb-4`;
      }
      if (cardTextElement) {
        cardTextElement.textContent = previewName ? `Simulation: ${previewName}` : "Ton style s'affiche ici quand tu equipes une carte.";
      }
    }

    if (previewType === "title" && titleElement) {
      titleElement.textContent = previewName ? `Titre: ${previewName}` : "Aucun titre equipe";
    }
  });
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", bindShopPreviewHandlers, { once: true });
} else {
  bindShopPreviewHandlers();
}
