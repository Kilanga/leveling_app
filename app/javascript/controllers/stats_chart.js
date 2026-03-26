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

  const pointValueLabelsPlugin = {
    id: "pointValueLabelsPlugin",
    afterDraw(chart) {
      const radial = chart.scales.r;
      const dataset = chart.data.datasets?.[0];
      if (!radial || !dataset || !Array.isArray(dataset.data)) return;

      const context = chart.ctx;
      context.save();
      context.fillStyle = "rgba(167, 205, 231, 0.9)";
      context.font = "11px system-ui, sans-serif";
      context.textAlign = "center";
      context.textBaseline = "middle";

      dataset.data.forEach((rawValue, axisIndex) => {
        const value = Number(rawValue);
        if (!Number.isFinite(value)) return;

        const labelPoint = radial.getPointPositionForValue(axisIndex, value + 0.45);

        context.fillText(String(value), labelPoint.x, labelPoint.y);
      });

      context.restore();
    }
  };

  new window.Chart(ctx, {
    plugins: [pointValueLabelsPlugin],
    type: "radar",
    data: {
      labels: statsData.map((stat) => stat.name),
      datasets: [
        {
          label: "Niveau",
          data: levels,
          backgroundColor: "rgba(58, 188, 238, 0.18)",
          borderColor: "#35b5e6",
          borderWidth: 2,
          pointBackgroundColor: "#66d8ff",
          pointBorderColor: "#e8f7ff",
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
          ticks: {
            stepSize: 1,
            display: false,
            color: "#a7cde7",
            backdropColor: "transparent",
            z: 10
          },
          grid: { display: false },
          angleLines: { display: false },
          pointLabels: { color: "#7ca8c8", font: { size: 12, weight: "600" } }
        }
      }
    }
  });
});
