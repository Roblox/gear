import { classDocsUrl } from "./roblox-docs.js";

const PAGE_SIZE = 50;
const state = {
  items: [],
  filtered: [],
  shown: PAGE_SIZE,
  letter: "all",
  sort: "az",
};

const grid = document.querySelector("#catalog-grid");
const count = document.querySelector("#result-count");
const title = document.querySelector("#catalog-title");
const search = document.querySelector("#search");
const searchForm = document.querySelector(".search-form");
const sortList = document.querySelector("#sort-list");
const alphabet = document.querySelector("#alphabet");
const loadMore = document.querySelector("#load-more");
const emptyState = document.querySelector("#empty-state");
const funFacts = document.querySelector("#fun-facts");

const number = new Intl.NumberFormat("en-US");
const letters = ["all", ..."ABCDEFGHIJKLMNOPQRSTUVWXYZ"];

// Missing created dates sort by asset id.
function createdAt(item) {
  const parsed = item.created ? Date.parse(item.created) : Number.NaN;
  return Number.isNaN(parsed) ? null : parsed;
}

const SORTS = {
  az: (a, b) => a.name.localeCompare(b.name),
  za: (a, b) => b.name.localeCompare(a.name),
  instances: (a, b) => b.instances - a.instances || a.name.localeCompare(b.name),
  fewest: (a, b) => a.instances - b.instances || a.name.localeCompare(b.name),
  newest: (a, b) => {
    const left = createdAt(a);
    const right = createdAt(b);
    if (left === null || right === null) return b.id - a.id;
    return right - left;
  },
  oldest: (a, b) => {
    const left = createdAt(a);
    const right = createdAt(b);
    if (left === null || right === null) return a.id - b.id;
    return left - right;
  },
};

function escapeHtml(value) {
  const element = document.createElement("span");
  element.textContent = value;
  return element.innerHTML;
}

function agoLabel(timestamp) {
  if (!timestamp) return "";
  const created = new Date(timestamp);
  if (Number.isNaN(created.getTime())) return "";
  const years = Math.floor((Date.now() - created.getTime()) / 31557600000);
  if (years < 1) return "this year";
  return `${years} year${years === 1 ? "" : "s"} ago`;
}

function priceLine(item) {
  if (typeof item.price === "number" && item.price > 0) {
    return `<div><span class="robux">R$: ${number.format(item.price)}</span></div>`;
  }
  if (item.priceStatus) {
    return `<div>${escapeHtml(item.priceStatus)}</div>`;
  }
  return "";
}

function card(item) {
  const name = escapeHtml(item.name);
  const image = item.thumbnail
    ? `<img src="${item.thumbnail}" alt="" loading="lazy" />`
    : `<span class="thumb-fallback" aria-hidden="true">${escapeHtml(item.name.slice(0, 1))}</span>`;
  const created = agoLabel(item.created);

  return `<a class="item" href="./gear.html?id=${item.id}">
    <span class="item-thumb">${image}</span>
    <span class="item-name">${name}</span>
    <span class="item-facts">
      <div><b>Creator:</b> ${escapeHtml(item.creator || "ROBLOX")}</div>
      ${created ? `<div><b>Created:</b> ${created}</div>` : ""}
      <div><b>Instances:</b> ${number.format(item.instances)}</div>
      ${
        typeof item.favorites === "number"
          ? `<div><b>Favorited:</b> ${number.format(item.favorites)} times</div>`
          : `<div><b>Asset ID:</b> ${item.id}</div>`
      }
      ${priceLine(item)}
    </span>
  </a>`;
}

function render() {
  const visible = state.filtered.slice(0, state.shown);
  grid.innerHTML = visible.map(card).join("");
  count.textContent = `${number.format(visible.length)} of ${number.format(
    state.filtered.length,
  )} ${state.filtered.length === 1 ? "item" : "items"}`;
  loadMore.hidden = visible.length >= state.filtered.length;
  emptyState.hidden = state.filtered.length !== 0;
  grid.hidden = state.filtered.length === 0;
}

function applyFilters() {
  const query = search.value.trim().toLocaleLowerCase();
  state.filtered = state.items.filter((item) => {
    const matchesSearch =
      query === "" ||
      item.name.toLocaleLowerCase().includes(query) ||
      String(item.id).includes(query);
    const initial = item.name[0]?.toLocaleUpperCase() ?? "#";
    const matchesLetter = state.letter === "all" || initial === state.letter;
    return matchesSearch && matchesLetter;
  });

  state.filtered.sort(SORTS[state.sort] ?? SORTS.az);

  const selected = sortList.querySelector(`a[data-sort="${state.sort}"]`);
  const base = selected?.dataset.title ?? "Gear";
  title.textContent = state.letter === "all" ? base : `${base}, Starting With "${state.letter}"`;
  state.shown = PAGE_SIZE;
  render();
}

function renderAlphabet() {
  const initials = new Set(state.items.map((item) => item.name[0]?.toLocaleUpperCase()));
  alphabet.innerHTML = letters
    .map((letter) => {
      const label = letter === "all" ? "All" : letter;
      const disabled = letter !== "all" && !initials.has(letter);
      return `<button type="button" data-letter="${letter}"${
        letter === state.letter ? ' class="selected"' : ""
      }${disabled ? " disabled" : ""}>${label}</button>`;
    })
    .join("");
}

function renderFunFacts(items) {
  if (!items.length) return;
  const pick = (compare) => items.reduce((best, item) => (compare(item, best) ? item : best));
  const link = (item, suffix) =>
    `<a href="./gear.html?id=${item.id}">${escapeHtml(item.name)}</a> ${suffix}`;

  const totalInstances = items.reduce((sum, item) => sum + item.instances, 0);
  const classTotals = new Map();
  for (const item of items) {
    for (const [className, count] of Object.entries(item.classes)) {
      classTotals.set(className, (classTotals.get(className) ?? 0) + count);
    }
  }
  const [topClass, topClassCount] = [...classTotals].sort((a, b) => b[1] - a[1])[0];

  const facts = [
    `${number.format(items.length)} gear preserved, holding ${number.format(
      totalInstances,
    )} instances across ${number.format(classTotals.size)} classes.`,
  ];

  const dated = items.filter((item) => createdAt(item) !== null);
  if (dated.length) {
    const oldest = dated.reduce((best, item) => (createdAt(item) < createdAt(best) ? item : best));
    facts.push(
      link(oldest, `is the oldest, from ${new Date(createdAt(oldest)).getFullYear()}.`),
    );
  }

  const datePrefixed = items.filter((item) => /^\d{1,2}\/\d{1,2}\b/.test(item.name));
  if (datePrefixed.length) {
    facts.push(
      datePrefixed.length === 1
        ? "1 gear is named with its release date."
        : `${number.format(datePrefixed.length)} gear are named with their release date.`,
    );
  }

  const biggest = pick((item, best) => item.instances > best.instances);
  facts.push(link(biggest, `is the biggest, at ${number.format(biggest.instances)} instances.`));

  const smallest = pick((item, best) => item.instances < best.instances);
  facts.push(link(smallest, `is the smallest, at just ${number.format(smallest.instances)}.`));

  const favorited = items.filter((item) => typeof item.favorites === "number");
  if (favorited.length) {
    const top = favorited.reduce((best, item) => (item.favorites > best.favorites ? item : best));
    facts.push(link(top, `is the most favorited, ${number.format(top.favorites)} times.`));
  }

  const topClassLink = `<a href="${escapeHtml(classDocsUrl(topClass))}">${escapeHtml(topClass)}</a>`;
  facts.push(`${topClassLink} is the most common class, used ${number.format(topClassCount)} times.`);

  funFacts.innerHTML = facts.map((fact) => `<li>${fact}</li>`).join("");
}

function markSort() {
  for (const link of sortList.querySelectorAll("a[data-sort]")) {
    link.classList.toggle("selected", link.dataset.sort === state.sort);
  }
}

alphabet.addEventListener("click", (event) => {
  const button = event.target.closest("button[data-letter]");
  if (!button) return;
  state.letter = button.dataset.letter;
  renderAlphabet();
  applyFilters();
});

sortList.addEventListener("click", (event) => {
  const link = event.target.closest("a[data-sort]");
  if (!link) return;
  event.preventDefault();
  state.sort = link.dataset.sort;
  markSort();
  applyFilters();
});

searchForm.addEventListener("submit", (event) => {
  event.preventDefault();
  applyFilters();
});
search.addEventListener("input", applyFilters);
loadMore.addEventListener("click", () => {
  state.shown += PAGE_SIZE;
  render();
});

async function start() {
  try {
    const response = await fetch("./data/catalog.json");
    if (!response.ok) throw new Error(`catalog returned ${response.status}`);
    const catalog = await response.json();
    state.items = catalog.items;
    search.value = new URLSearchParams(window.location.search).get("q") ?? "";
    renderAlphabet();
    renderFunFacts(state.items);
    markSort();
    applyFilters();
  } catch (error) {
    count.textContent = "";
    grid.hidden = true;
    emptyState.hidden = false;
    emptyState.innerHTML =
      "<strong>The catalog is unavailable.</strong><br />Please try again in a moment.";
    console.error(error);
  }
}

start();
