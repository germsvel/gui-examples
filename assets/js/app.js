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
    let canvas = this.el;
    let ctx = this.el.getContext('2d');
    let circle = new Path2D();

    // ctx.arc(x, y, radius, startAngle, endAngle [, counterclockwise]);

    this.el.addEventListener("click", (e) => {
      let rect = canvas.getBoundingClientRect()
      console.log(e)
      console.log(e.clientX)
      console.log(e.clientY)
      let x = e.clientX - rect.left
      let y = e.clientY - rect.top
      circle.arc(x, y, 25, 0, 2 * Math.PI);
      ctx.fill(circle);
    });

    this.el.addEventListener("reset", () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
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

