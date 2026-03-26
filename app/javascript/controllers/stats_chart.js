document.addEventListener("DOMContentLoaded", () => {
  const canvas = document.getElementById("statsChart");
  if (!canvas || typeof window.Chart === "undefined") return;

  let statsData = [];
  try {
    statsData = JSON.parse(canvas.dataset.stats || "[]");
  } catch (_error) {
    statsData = [];
  }

  if (!Array.isArray(statsData) || statsData.length === 0) return;

  const levels = statsData.map((stat) => stat.level || 0);
  const maxLevel = Math.max(...levels, 1);
  const ctx = canvas.getContext("2d");

  new window.Chart(ctx, {
    type: "radar",
    data: {
      labels: statsData.map((stat) => stat.name),
      datasets: [
        {
          label: "Niveau",
          data: levels,
          backgroundColor: "rgba(124, 77, 31, 0.18)",
          borderColor: "#7c4d1f",
          borderWidth: 2,
          pointBackgroundColor: "#bc7a32",
          pointBorderColor: "#fff9ef",
          pointBorderWidth: 2,
          pointRadius: 5,
          pointHoverRadius: 7
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: (context) => {
              const row = statsData[context.dataIndex];
              return `Niveau ${row.level} - ${row.xp}/${row.xp_needed} XP`;
            }
          }
        }
      },
      scales: {
        r: {
          beginAtZero: true,
          suggestedMin: 0,
          suggestedMax: maxLevel + 2,
          ticks: { stepSize: 1, backdropColor: "transparent", color: "#7a6750" },
          grid: { color: "rgba(124, 77, 31, 0.2)" },
          angleLines: { color: "rgba(124, 77, 31, 0.2)" },
          pointLabels: { color: "#4c3b25", font: { size: 12, weight: "600" } }
        }
      }
    }
  });
});
