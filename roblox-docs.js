const CLASS_DOCS_BASE = "https://create.roblox.com/docs/reference/engine/classes";

export function classDocsUrl(className) {
  return `${CLASS_DOCS_BASE}/${encodeURIComponent(className)}`;
}

export function classDocsLink(className) {
  const link = document.createElement("a");
  link.href = classDocsUrl(className);
  link.textContent = className;
  return link;
}
