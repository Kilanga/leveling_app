function selectedCategoryIds(form) {
  return Array.from(form.querySelectorAll("input[name='category_ids[]']:checked"))
    .map((input) => Number.parseInt(input.value, 10))
    .filter((id) => Number.isInteger(id) && id > 0);
}

function parseQuestPool(container) {
  try {
    const json = container.dataset.questPool || "[]";
    const parsed = JSON.parse(json);
    return Array.isArray(parsed) ? parsed : [];
  } catch (_error) {
    return [];
  }
}

function buildRecommendations(questPool, selectedIds) {
  if (!selectedIds.length) {
    return [];
  }

  const selected = new Set(selectedIds);
  return questPool
    .filter((quest) => selected.has(Number(quest.category_id)))
    .slice(0, 6);
}

function renderRecommendations(list, recommendations, emptyMessage) {
  list.innerHTML = "";

  if (!recommendations.length) {
    const empty = document.createElement("p");
    empty.className = "quest-meta mb-0";
    empty.textContent = emptyMessage;
    list.appendChild(empty);
    return;
  }

  const wrapper = document.createElement("div");
  wrapper.className = "quest-list quest-list--flat";

  recommendations.forEach((quest) => {
    const row = document.createElement("div");
    row.className = "quest-row quest-row--flat";

    const title = document.createElement("strong");
    title.textContent = quest.title || "Mission";

    const meta = document.createElement("p");
    meta.className = "quest-meta mb-0";
    const category = quest.category_name || "Categorie";
    const xp = Number(quest.xp) || 0;
    meta.textContent = `${category} - ${xp} XP`;

    row.appendChild(title);
    row.appendChild(meta);
    wrapper.appendChild(row);
  });

  list.appendChild(wrapper);
}

function initOnboardingPreview() {
  const form = document.getElementById("onboarding-form");
  const container = document.getElementById("onboarding-recommendations");
  const list = document.getElementById("onboarding-recommendations-list");

  if (!form || !container || !list) {
    return;
  }

  if (form.dataset.onboardingPreviewBound === "1") {
    return;
  }

  const questPool = parseQuestPool(container);
  const emptyMessage = container.dataset.emptyMessage || "Selectionne des categories pour voir tes recommandations.";

  const update = () => {
    const selectedIds = selectedCategoryIds(form);
    const recommendations = buildRecommendations(questPool, selectedIds);
    renderRecommendations(list, recommendations, emptyMessage);
  };

  form.addEventListener("change", (event) => {
    if (!(event.target instanceof HTMLInputElement)) {
      return;
    }
    if (event.target.name !== "category_ids[]") {
      return;
    }
    update();
  });

  form.dataset.onboardingPreviewBound = "1";
  update();
}

document.addEventListener("turbo:load", initOnboardingPreview);
