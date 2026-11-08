// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";
import "@fontsource/roboto/latin-400.css";
import "@fontsource/roboto/latin-400-italic.css";
import "@fontsource/roboto/latin-500.css";
import "@fontsource/roboto/latin-700.css";
import "../css/contact-main.css";
import "bootstrap.native";
import Prism from "prismjs";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//

Prism.highlightAll();

document.querySelectorAll(".post-container pre > code").forEach((code) => {
  const pre = code.parentElement;
  const wrapper = document.createElement("div");
  wrapper.className = "code-block";
  pre.parentNode.insertBefore(wrapper, pre);
  wrapper.appendChild(pre);

  const button = document.createElement("button");
  button.type = "button";
  button.className = "copy-code-button";
  button.textContent = "Copy";
  button.setAttribute("aria-label", "Copy code to clipboard");
  button.addEventListener("click", () => {
    navigator.clipboard.writeText(code.innerText).then(
      () => (button.textContent = "Copied!"),
      () => (button.textContent = "Failed")
    );
    setTimeout(() => (button.textContent = "Copy"), 2000);
  });
  wrapper.appendChild(button);
});

import "phoenix_html";
