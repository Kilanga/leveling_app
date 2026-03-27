function selectedCategoryIds(form) {
  return Array.from(form.querySelectorAll("input[name='category_ids[]']:checked"))
    .map((input) => Number.parseInt(input.value, 10))
    .filter((id) => Number.isInteger(id) && id > 0);
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

async function fetchRecommendations(endpoint, selectedIds) {
  if (!endpoint || !selectedIds.length) {
    return [];
  }

  const query = new URLSearchParams();
  selectedIds.forEach((id) => query.append("category_ids[]", String(id)));

  const response = await fetch(`${endpoint}?${query.toString()}`, {
    method: "GET",
    headers: {
      Accept: "application/json"
    }
  });

  if (!response.ok) {
    return [];
  }

  const payload = await response.json();
  return Array.isArray(payload) ? payload : [];
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

  const endpoint = container.dataset.recommendationsEndpoint || "";
  const selectedQuestIds = parseSelectedQuestIds(container);
  const emptyMessage = container.dataset.emptyMessage || "Selectionne des categories pour voir tes recommandations.";

  const syncSelectedQuestIdsFromDom = () => {
    selectedQuestIds.clear();
    Array.from(form.querySelectorAll("input[name='quest_ids[]']:checked")).forEach((input) => {
      const questId = Number.parseInt(input.value, 10);
      if (Number.isInteger(questId) && questId > 0) {
        selectedQuestIds.add(questId);
      }
    });
  };

  const update = async () => {
    syncSelectedQuestIdsFromDom();
    const selectedIds = selectedCategoryIds(form);
    if (!selectedIds.length) {
      selectedQuestIds.clear();
      renderRecommendations(list, [], emptyMessage, selectedQuestIds);
      return;
    }

    const recommendations = await fetchRecommendations(endpoint, selectedIds);
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
      void update();
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
  void update();
}

document.addEventListener("turbo:load", initOnboardingPreview);
