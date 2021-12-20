// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

let Hooks = {}

Hooks.Slider = {
  mounted() {
    this.el.addEventListener("input", (e) => {
      this.pushEvent("update-duration", {value: e.target.value});
    });
  }
}

Hooks.CircleDrawer = {
  mounted() {
    let svg = this.el;

    this.el.addEventListener("click", (e) => {
      let pt = svg.createSVGPoint();

      // pass event coordinates
      pt.x = e.clientX;
      pt.y = e.clientY;

      // transform to SVG coordinates
      let svgP = pt.matrixTransform(svg.getScreenCTM().inverse());
      let x = svgP.x;
      let y = svgP.y;

      this.pushEvent("canvas-click", {x, y})
    });

    this.el.addEventListener("contextmenu", (e) => {
      e.preventDefault();

      let modal = document.getElementById("modal");
      let content = document.getElementById("modal-content");
      modal.style.display = "block";
      content.style.display = "block";
      return false
    })
  }
}

Hooks.CircleDiameterSlider = {
  mounted() {
    this.el.addEventListener("input", (e) => {
      let radius = e.target.value;
      let selected = document.getElementById("selected-circle");

      selected.setAttribute('r', radius)
    });

    this.el.addEventListener("update-selected-radius", (e) => {
      let radius = e.target.value;

      this.pushEvent("selected-circle-radius-updated", {r: radius});
    });
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

