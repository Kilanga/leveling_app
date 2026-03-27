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

function parseSelectedQuestIds(container) {
  const raw = (container.dataset.selectedQuestIds || "").trim();
  if (!raw) {
    return new Set();
  }

  const ids = raw
    .split(",")
    .map((value) => Number.parseInt(value, 10))
    .filter((id) => Number.isInteger(id) && id > 0);

  return new Set(ids);
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

function renderRecommendations(list, recommendations, emptyMessage, selectedQuestIds) {
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

    const label = document.createElement("label");
    label.className = "d-flex align-items-start gap-2 mb-0 tutorial-quest-label";

    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.name = "quest_ids[]";
    checkbox.value = String(quest.id || "");
    checkbox.className = "mt-1";
    checkbox.checked = selectedQuestIds.has(Number(quest.id));

    const textWrap = document.createElement("span");

    const title = document.createElement("strong");
    title.textContent = quest.title || "Mission";

    const meta = document.createElement("span");
    meta.className = "quest-meta d-block";
    const category = quest.category_name || "Categorie";
    const xp = Number(quest.xp) || 0;
    meta.textContent = `${category} - ${xp} XP`;

    textWrap.appendChild(title);
    textWrap.appendChild(meta);
    label.appendChild(checkbox);
    label.appendChild(textWrap);
    row.appendChild(label);
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
  const selectedQuestIds = parseSelectedQuestIds(container);
  const emptyMessage = container.dataset.emptyMessage || "Selectionne des categories pour voir tes recommandations.";

  const update = () => {
    const selectedIds = selectedCategoryIds(form);
    const recommendations = buildRecommendations(questPool, selectedIds);
    const visibleIds = new Set(recommendations.map((quest) => Number(quest.id)));
    Array.from(selectedQuestIds).forEach((questId) => {
      if (!visibleIds.has(questId)) {
        selectedQuestIds.delete(questId);
      }
    });
    renderRecommendations(list, recommendations, emptyMessage, selectedQuestIds);
  };

  form.addEventListener("change", (event) => {
    if (!(event.target instanceof HTMLInputElement)) {
      return;
    }
    if (event.target.name === "category_ids[]") {
      update();
      return;
    }
    if (event.target.name === "quest_ids[]") {
      const questId = Number.parseInt(event.target.value, 10);
      if (!Number.isInteger(questId) || questId <= 0) {
        return;
      }
      if (event.target.checked) {
        selectedQuestIds.add(questId);
      } else {
        selectedQuestIds.delete(questId);
      }
    }
  });

  form.dataset.onboardingPreviewBound = "1";
  update();
}

document.addEventListener("turbo:load", initOnboardingPreview);
