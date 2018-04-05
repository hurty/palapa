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
import "phoenix_html"
import { Application } from "stimulus"

import ChoiceController from "./controllers/choice_controller"
import FilterController from "./controllers/filter_controller"
import NavigationController from "./controllers/navigation_controller"
import TextEditorController from "./controllers/text_editor_controller"
import MessageController from "./controllers/message_controller"

const application = Application.start()
application.register("choice", ChoiceController)
application.register("filter", FilterController)
application.register("navigation", NavigationController)
application.register("text_editor", TextEditorController)
application.register("message", MessageController)
