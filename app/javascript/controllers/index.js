// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
// import DashboardController from "./dashboard_controller"
eagerLoadControllersFrom("controllers", application)

// application.register("dashboard", DashboardController)
