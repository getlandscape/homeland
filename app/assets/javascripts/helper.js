function replaceHTML(element, content) {
    element.html(content);
    document.dispatchEvent(new CustomEvent('PartiallyReplaced', {detail: element}));
}
