// Compte à rebours des offres du jour (rotation à minuit).
(() => {
  if (window.__dealCountdownBound) return;
  window.__dealCountdownBound = true;

  const pad = (value) => String(value).padStart(2, "0");

  const tick = () => {
    document.querySelectorAll(".js-deal-countdown").forEach((el) => {
      const deadline = new Date(el.dataset.deadline);
      if (Number.isNaN(deadline.getTime())) return;

      const remaining = Math.max(0, Math.floor((deadline - new Date()) / 1000));
      const hours = Math.floor(remaining / 3600);
      const minutes = Math.floor((remaining % 3600) / 60);
      const seconds = remaining % 60;
      el.textContent = `⏳ ${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
    });
  };

  document.addEventListener("DOMContentLoaded", () => {
    if (!document.querySelector(".js-deal-countdown")) return;
    tick();
    setInterval(tick, 1000);
  });
})();
