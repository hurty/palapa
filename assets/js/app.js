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

// Global events handlers
import "./handlers/external_links_handler"
import "./handlers/trix_attachments_handler"

// Components
import AvatarController from "./controllers/avatar_controller"
import PopoverController from "./controllers/popover_controller"
import EditorController from "./controllers/editor_controller"
import TextareaAutoresizeController from "./controllers/textarea_autoresize_controller"
import ChoiceController from "./controllers/choice_controller"

// Specific pages
import RegistrationController from "./controllers/registration_controller"
import FilterController from "./controllers/filter_controller"
import NavigationController from "./controllers/navigation_controller"
import MessageController from "./controllers/message_controller"

const application = Application.start()

// Components
application.register("avatar", AvatarController)
application.register("popover", PopoverController)
application.register("editor", EditorController)
application.register("textarea_autoresize", TextareaAutoresizeController)
application.register("choice", ChoiceController)

// Specific pages
application.register("registration", RegistrationController)
application.register("filter", FilterController)
application.register("navigation", NavigationController)
application.register("message", MessageController)
