window.MathJax = {
    jax: ["input/MathML", "output/HTML-CSS"],
    extensions: ["mml2jax.js", "MathML/content-mathml.js", "MathZoom.js"],
    menuSettings: { zoom: "Click" },
    CommonHTML: {linebreaks: { automatic: true, width: "container" }},
    "HTML-CSS": {
        linebreaks: { automatic: true, width: "container" },
        EqnChunk: 1,
        EqnChunkFactor: 1,
        EqnChunkDelay: 1
    },
    SVG: { linebreaks: { automatic: true, width: "container" } }
};
