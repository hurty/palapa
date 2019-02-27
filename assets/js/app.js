import css from "../css/app.css"
import "./vendor/fontawesome"
import "./vendor/fontawesome-solid"
import "./vendor/fontawesome-brands"

import "./palapa"
import Trix from "trix"

// Global events handlers
import "./handlers/external_links_handler"

// Load all Stimulus controllers
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
const application = Application.start()
const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))
