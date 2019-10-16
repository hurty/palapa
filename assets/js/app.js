import css from "../css/app.css";
import "./vendor/fontawesome";
import "./vendor/fontawesome-solid";
import "./vendor/fontawesome-brands";

import "./palapa";
import "trix";

import AutoFocus from "./live_hooks/auto_focus";
let Hooks = {};
Hooks.AutoFocus = AutoFocus;

import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks });
liveSocket.connect();

// Global events handlers
import "./handlers/external_links_handler";

// Load all Stimulus controllers
import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";
const application = Application.start();
const context = require.context("./controllers", true, /\.js$/);
application.load(definitionsFromContext(context));
