// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "./palapa"
import "phoenix_html"
import { Application } from "stimulus"
import "trix"

import PopoverController from "./controllers/popover_controller"
import EditorController from "./controllers/editor_controller"

import ChoiceController from "./controllers/choice_controller"
import FilterController from "./controllers/filter_controller"
import NavigationController from "./controllers/navigation_controller"
import MessageController from "./controllers/message_controller"

const application = Application.start()

application.register("popover", PopoverController)
application.register("editor", EditorController)

application.register("choice", ChoiceController)
application.register("filter", FilterController)
application.register("navigation", NavigationController)
application.register("message", MessageController)

// Open all external links in a new window
addEventListener("click", function (event) {
  var el = event.target

  if (el.tagName === "A" && !el.isContentEditable && el.host !== window.location.host) {
    el.setAttribute("target", "_blank")
  }
}, true)
