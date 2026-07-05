document.addEventListener("DOMContentLoaded", () => {
  const canvas = document.getElementById("weeklyStatsChart")
  if (!canvas || typeof window.Chart === "undefined") return

  let series = []
  try { series = JSON.parse(canvas.dataset.series || "[]") } catch (_e) { return }
  if (!Array.isArray(series) || series.length === 0) return

  new window.Chart(canvas.getContext("2d"), {
    type: "bar",
    data: {
      labels: series.map((w) => w.label),
      datasets: [
        {
          type: "line",
          label: canvas.dataset.xpLabel,
          data: series.map((w) => w.xp),
          borderColor: "#2ab8f2",
          backgroundColor: "rgba(42, 184, 242, 0.25)",
          tension: 0.3,
          yAxisID: "y"
        },
        {
          type: "bar",
          label: canvas.dataset.completionsLabel,
          data: series.map((w) => w.completions),
          backgroundColor: "rgba(125, 220, 255, 0.35)",
          borderColor: "rgba(125, 220, 255, 0.8)",
          borderWidth: 1,
          yAxisID: "y1"
        }
      ]
    },
    options: {
      responsive: true,
      scales: {
        y: { beginAtZero: true, position: "left", ticks: { color: "#9eb6cd" }, grid: { color: "rgba(40, 75, 109, 0.35)" } },
        y1: { beginAtZero: true, position: "right", grid: { drawOnChartArea: false }, ticks: { color: "#9eb6cd", precision: 0 } },
        x: { ticks: { color: "#9eb6cd" }, grid: { display: false } }
      },
      plugins: { legend: { labels: { color: "#e9f4ff" } } }
    }
  })
})
