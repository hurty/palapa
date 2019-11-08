import css from "../css/app.css";
import "./vendor/fontawesome";
import "./vendor/fontawesome-solid";
import "./vendor/fontawesome-brands";

import "./palapa";

import Trix from "trix";
Trix.config.attachments.preview.presentation = null;

import MicroModal from "micromodal";
MicroModal.init();

let serializeForm = form => {
  let formData = new FormData(form);
  let params = new URLSearchParams();
  for (let [key, val] of formData.entries()) {
    params.append(key, val);
  }

  return params.toString();
};

let Params = {
  data: {},
  set(namespace, key, val) {
    if (!this.data[namespace]) {
      this.data[namespace] = {};
    }
    this.data[namespace][key] = val;
  },
  get(namespace) {
    return this.data[namespace] || {};
  }
};

let SavedForm = {
  mounted() {
    this.el.addEventListener("input", e => {
      Params.set(this.viewName, "stashed_form", serializeForm(this.el));
    });
  }
};

import AutoFocus from "./live_hooks/auto_focus";
import Choices from "./live_hooks/choices";

let Hooks = {
  AutoFocus: AutoFocus,
  SavedForm: SavedForm,
  Choices: Choices
};

import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: view => Params.get(view)
});
liveSocket.connect();

// Global events handlers
import "./handlers/external_links_handler";

// Load all Stimulus controllers
import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";
const application = Application.start();
const context = require.context("./controllers", true, /\.js$/);
application.load(definitionsFromContext(context));
