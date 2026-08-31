const params = new URLSearchParams(window.location.search);
const assetId = params.get("id");
const loading = document.querySelector("#detail-loading");
const errorState = document.querySelector("#detail-error");
const detail = document.querySelector("#gear-detail");
const treeContainer = document.querySelector("#instance-tree");
const inspector = document.querySelector("#node-inspector");
const treeSearch = document.querySelector("#tree-search");
const expandButton = document.querySelector("#expand-tree");
const searchForm = document.querySelector(".search-form");
const search = document.querySelector("#search");
const number = new Intl.NumberFormat("en-US");

function showError() {
  loading.hidden = true;
  detail.hidden = true;
  errorState.hidden = false;
}

function fact(label, value) {
  const element = document.createElement("div");
  const name = document.createElement("b");
  name.textContent = `${label}:`;
  element.append(name, ` ${value}`);
  return element;
}

function setImage(item) {
  const image = document.querySelector("#gear-image");
  const wrap = image.parentElement;
  if (!item.thumbnail) {
    image.remove();
    const fallback = document.createElement("span");
    fallback.className = "thumb-fallback";
    fallback.setAttribute("aria-hidden", "true");
    fallback.textContent = item.name.slice(0, 1);
    wrap.append(fallback);
    return;
  }
  image.addEventListener("error", () => image.remove());
  image.alt = `${item.name} thumbnail`;
  image.src = item.thumbnail;
}

function showInspector(node) {
  inspector.replaceChildren();
  const title = document.createElement("h3");
  title.textContent = node.n;
  const className = document.createElement("p");
  className.className = "class-name";
  className.textContent = node.c;
  const count = document.createElement("p");
  count.className = "inspector-count";
  count.textContent = `${node.p.length} serialized ${node.p.length === 1 ? "property" : "properties"}`;
  inspector.append(title, className, count);

  if (node.p.length) {
    const list = document.createElement("ul");
    list.className = "property-list";
    for (const property of node.p) {
      const item = document.createElement("li");
      item.textContent = property;
      list.append(item);
    }
    inspector.append(list);
  } else {
    const message = document.createElement("p");
    message.className = "inspector-hint";
    message.textContent = "This instance only uses its class defaults.";
    inspector.append(message);
  }
}

function setOpen(item, open) {
  item.classList.toggle("open", open);
  const toggle = item.querySelector(":scope > .tree-row > .tree-toggle");
  const list = item.querySelector(":scope > ul");
  if (toggle) toggle.setAttribute("aria-expanded", String(open));
  if (list) list.hidden = !open;
}

function buildTreeNode(node, depth = 0) {
  const item = document.createElement("li");
  item.dataset.search = `${node.n} ${node.c}`.toLocaleLowerCase();
  const hasChildren = Boolean(node.k?.length);
  const row = document.createElement("div");
  row.className = "tree-row";
  let childList = null;

  if (hasChildren) {
    const toggle = document.createElement("button");
    toggle.type = "button";
    toggle.className = "tree-toggle";
    toggle.setAttribute("aria-label", `Toggle ${node.n}`);
    toggle.addEventListener("click", () => setOpen(item, !item.classList.contains("open")));
    row.append(toggle);
    childList = document.createElement("ul");
    for (const child of node.k) childList.append(buildTreeNode(child, depth + 1));
  } else {
    const spacer = document.createElement("span");
    spacer.className = "tree-spacer";
    spacer.setAttribute("aria-hidden", "true");
    row.append(spacer);
  }

  const button = document.createElement("button");
  button.type = "button";
  button.className = "tree-node";
  const name = document.createElement("strong");
  name.textContent = node.n;
  const className = document.createElement("span");
  className.textContent = node.c;
  button.append(name, className);
  button.addEventListener("click", () => {
    treeContainer.querySelectorAll(".tree-node.selected").forEach((selected) => {
      selected.classList.remove("selected");
    });
    button.classList.add("selected");
    showInspector(node);
  });
  row.append(button);
  item.append(row);

  if (childList) {
    item.append(childList);
    setOpen(item, depth < 2);
  }
  return item;
}

function renderTree(tree) {
  const root = document.createElement("ul");
  root.className = "tree-root";
  root.append(buildTreeNode(tree));
  treeContainer.replaceChildren(root);
}

function filterTree(query) {
  const normalized = query.trim().toLocaleLowerCase();
  const items = [...treeContainer.querySelectorAll("li")];
  if (!normalized) {
    for (const item of items) item.hidden = false;
    return;
  }
  for (const item of items.reverse()) {
    const directMatch = item.dataset.search.includes(normalized);
    const childMatch = [...item.querySelectorAll(":scope > ul > li")].some((child) => !child.hidden);
    item.hidden = !directMatch && !childMatch;
    if (!item.hidden) setOpen(item, true);
  }
}

treeSearch.addEventListener("input", () => filterTree(treeSearch.value));
expandButton.addEventListener("click", () => {
  const branches = [...treeContainer.querySelectorAll("li:has(> ul)")];
  const shouldExpand = branches.some((branch) => !branch.classList.contains("open"));
  for (const branch of branches) setOpen(branch, shouldExpand);
  expandButton.textContent = shouldExpand ? "Collapse All" : "Expand All";
});

searchForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const query = search.value.trim();
  window.location.href = query ? `./index.html?q=${encodeURIComponent(query)}` : "./index.html";
});

async function start() {
  if (!assetId || !/^\d+$/.test(assetId)) {
    showError();
    return;
  }

  try {
    const [catalogResponse, treeResponse] = await Promise.all([
      fetch("./data/catalog.json"),
      fetch(`./data/gear/${assetId}.json`),
    ]);
    if (!catalogResponse.ok || !treeResponse.ok) throw new Error("Gear data not found");
    const [catalog, tree] = await Promise.all([catalogResponse.json(), treeResponse.json()]);
    const item = catalog.items.find((candidate) => String(candidate.id) === assetId);
    if (!item) throw new Error("Gear is missing from the catalog");

    document.title = `${item.name} - Roblox Gear`;
    document.querySelector("#gear-name").textContent = item.name;
    document.querySelector("#gear-crumb").textContent = item.name;
    const description = document.querySelector("#gear-description");
    const descriptionText = (item.description || "").trim();
    if (descriptionText) {
      description.textContent = descriptionText;
    } else {
      description.remove();
    }
    document.querySelector("#catalog-link").href = `https://www.roblox.com/catalog/${item.id}`;
    document.querySelector("#source-link").href =
      `https://github.com/Roblox/gear/tree/main/src/gear/${item.id}`;
    setImage(item);

    const facts = document.querySelector("#gear-facts");
    facts.append(fact("Creator", item.creator || "ROBLOX"));
    facts.append(fact("Asset ID", item.id));
    facts.append(fact("Instances", number.format(item.instances)));
    facts.append(fact("Unique Classes", number.format(Object.keys(item.classes).length)));
    if (typeof item.favorites === "number") {
      facts.append(fact("Favorited", `${number.format(item.favorites)} times`));
    }
    if (typeof item.price === "number" && item.price > 0) {
      facts.append(fact("Price", `R$ ${number.format(item.price)}`));
    } else if (item.priceStatus) {
      facts.append(fact("Price", item.priceStatus));
    }

    renderTree(tree);
    loading.hidden = true;
    detail.hidden = false;
  } catch (error) {
    console.error(error);
    showError();
  }
}

start();
