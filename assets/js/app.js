import css from "../css/app.css"
import "./vendor/fontawesome"
import "./vendor/fontawesome-solid"

import "./palapa"
import "phoenix_html"
import "trix"

// Global events handlers
import "./handlers/external_links_handler"

// Load all Stimulus controllers
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
const application = Application.start()
const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))
