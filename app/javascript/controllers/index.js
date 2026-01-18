import { application } from "./application"

// Import and register all your controllers here
import ChartController from "./chart_controller.js"
application.register("chart", ChartController)
