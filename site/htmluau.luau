export type Element = () -> string
export type Node = string | Element
export type ElementList = { Element }
export type Child = string | Element | ChildElement | ElementList
export type ChildElement = <T>(children: { T }?) -> Element
export type Component<T> = (props: T) -> ChildElement

local function escapeHtml(attribute: string): string
	attribute = string.gsub(attribute, "&", "&amp;")
	attribute = string.gsub(attribute, "<", "&lt;")
	attribute = string.gsub(attribute, ">", "&gt;")
	attribute = string.gsub(attribute, "'", "&apos;")
	attribute = string.gsub(attribute, '"', "&quot;")
	return attribute
end

local renderChild: (Child, { string }) -> ()

local function renderChildren(children: { Child }, stringChildren: { string })
	for _, child in children do
		renderChild(child, stringChildren)
	end
end

renderChild = function(child: Child, stringChildren: { string })
	if typeof(child) == "function" then
		local render = child :: () -> Node
		local rendered = render()
		if typeof(rendered) == "function" then
			table.insert(stringChildren, rendered())
		else
			table.insert(stringChildren, rendered)
		end
	elseif typeof(child) == "table" then
		for _, nestedChild in child :: { Element | string } do
			if typeof(nestedChild) == "string" then
				table.insert(stringChildren, nestedChild)
			else
				renderChild(nestedChild, stringChildren)
			end
		end
	else
		table.insert(stringChildren, escapeHtml(child))
	end
end

local function createComponent<T>(component: (props: T, children: { string }?) -> Node): Component<T>
	return function(props: T)
		local childElement = function(children: { Child }?)
			local stringChildren: { string }?
			if children then
				stringChildren = {}
				renderChildren(children, stringChildren)
			end

			return function()
				local result = component(props, stringChildren)
				if typeof(result) == "function" then
					return result()
				else
					return result
				end
			end
		end

		return childElement :: ChildElement
	end
end

local function createHtmlElement(tag: string)
	local function htmlElement(props: { [string]: string }?, children: { string }?)
		local attributes = ""
		if props then
			for key, value in props do
				attributes ..= ` {key}="{escapeHtml(value)}"`
			end
		end

		if children then
			return `<{tag}{attributes}>{table.concat(children, "\n")}</{tag}>`
		else
			return `<{tag}{attributes}></{tag}>`
		end
	end

	return createComponent(htmlElement)
end

local function map<K, V>(items: { [K]: V }, callback: (V, K) -> Element): ElementList
	local children: ElementList = {}
	for key, value in items do
		table.insert(children, callback(value, key))
	end
	return children
end

return {
	createComponent = createComponent,
	map = map,

	div = createHtmlElement("div"),
	span = createHtmlElement("span"),
	h1 = createHtmlElement("h1"),
	h2 = createHtmlElement("h2"),
	h3 = createHtmlElement("h3"),
	h4 = createHtmlElement("h4"),
	h5 = createHtmlElement("h5"),
	h6 = createHtmlElement("h6"),
	p = createHtmlElement("p"),
	a = createHtmlElement("a"),
	img = createHtmlElement("img"),
	button = createHtmlElement("button"),
	input = createHtmlElement("input"),
	label = createHtmlElement("label"),
	textarea = createHtmlElement("textarea"),
	select = createHtmlElement("select"),
	option = createHtmlElement("option"),
	ul = createHtmlElement("ul"),
	ol = createHtmlElement("ol"),
	li = createHtmlElement("li"),
	table = createHtmlElement("table"),
	tr = createHtmlElement("tr"),
	td = createHtmlElement("td"),
	th = createHtmlElement("th"),
	thead = createHtmlElement("thead"),
	tbody = createHtmlElement("tbody"),
	tfoot = createHtmlElement("tfoot"),
	form = createHtmlElement("form"),
	br = createHtmlElement("br"),
	hr = createHtmlElement("hr"),
	strong = createHtmlElement("strong"),
	b = createHtmlElement("b"),
	em = createHtmlElement("em"),
	i = createHtmlElement("i"),
	u = createHtmlElement("u"),
	s = createHtmlElement("s"),
	sup = createHtmlElement("sup"),
	sub = createHtmlElement("sub"),
	small = createHtmlElement("small"),
	code = createHtmlElement("code"),
	pre = createHtmlElement("pre"),
	blockquote = createHtmlElement("blockquote"),
	nav = createHtmlElement("nav"),
	header = createHtmlElement("header"),
	footer = createHtmlElement("footer"),
	section = createHtmlElement("section"),
	article = createHtmlElement("article"),
	aside = createHtmlElement("aside"),
	main = createHtmlElement("main"),
	details = createHtmlElement("details"),
	summary = createHtmlElement("summary"),
	dialog = createHtmlElement("dialog"),
	time = createHtmlElement("time"),
	address = createHtmlElement("address"),
	mark = createHtmlElement("mark"),
	progress = createHtmlElement("progress"),
	meter = createHtmlElement("meter"),
	caption = createHtmlElement("caption"),
	figure = createHtmlElement("figure"),
	figcaption = createHtmlElement("figcaption"),
	legend = createHtmlElement("legend"),
	fieldset = createHtmlElement("fieldset"),
	dfn = createHtmlElement("dfn"),
	kbd = createHtmlElement("kbd"),
	var = createHtmlElement("var"),
	cite = createHtmlElement("cite"),
	q = createHtmlElement("q"),

	html = createHtmlElement("html"),
	head = createHtmlElement("head"),
	title = createHtmlElement("title"),
	meta = createHtmlElement("meta"),
	link = createHtmlElement("link"),
	style = createHtmlElement("style"),
	body = createHtmlElement("body"),

	script = createHtmlElement("script"),
	noscript = createHtmlElement("noscript"),

	audio = createHtmlElement("audio"),
	video = createHtmlElement("video"),
	source = createHtmlElement("source"),
	track = createHtmlElement("track"),
	iframe = createHtmlElement("iframe"),
	canvas = createHtmlElement("canvas"),
	svg = createHtmlElement("svg"),
}
