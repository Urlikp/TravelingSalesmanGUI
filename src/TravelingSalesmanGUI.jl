module TravelingSalesmanGUI

using JSON, GLMakie

include("Constants.jl")

export GUI, get_slider_values, get_button_values, set_button_value, update_gui

mutable struct MyGraphics
    sliders::Dict{String, Union{Int, Float64}} # Slider buttons (mapping label to value)
    buttons::Dict{String, Bool} # Buttons (mapping label to on/off bool)
    axis::Makie.Axis   # Axis containing current best found cities sequence
    lines::Any  # Current best found cities sequence
    best_axis_grid::Any # Grid containing overall best found cities sequence
    best_axis::Makie.Axis  # Axis containing overall best found cities sequence
    best_lines::Any # Overall best found cities sequence
    best_label_grid::Any  # Info about run
end

mutable struct GUI
    cities::Dict{String, Any}
    best_entry::Union{Dict{String, Any}, Nothing}
    graphics::MyGraphics

    function GUI(params::Dict)
        set_theme!(theme_dark())
        resolution = (params["gui"]["params"]["height"], params["gui"]["params"]["width"])
        figure = Figure(resolution = resolution)

        name_label = "Traveling Salesman - " * params["problem_name"] * " - " * params["algorithm"]["name"]
        figure[0, 1:2] = Label(figure, name_label, fontsize = 30)

        axis_grid = figure[1, 1] = GridLayout()
        button_grid = figure[2, 1:2] = GridLayout()
        slider_grid = figure[3, 1:2] = GridLayout()
        best_found_grid = figure[1, 2] = GridLayout()

        best_label_grid = best_found_grid[1, 1] = GridLayout()
        best_axis_grid = best_found_grid[1, 2] = GridLayout()

        # ---------------------- Current Route ----------------------
        axis = Axis(axis_grid[1, 1], title = "Current Route", xlabel = "x", ylabel = "y")

        route = collect(keys(params["cities"]["position"]))
        starting_city = params["cities"]["start"]
        route_without_start = [label for label in route if label != starting_city]

        x_start = params["cities"]["position"][starting_city][1]
        y_start = params["cities"]["position"][starting_city][2]

        x_coords = [params["cities"]["position"][label][1] for label in route_without_start]
        y_coords = [params["cities"]["position"][label][2] for label in route_without_start]

        axis_offset = 2

        x_max = maximum([x_start; x_coords]) + axis_offset
        x_min = minimum([x_start; x_coords]) - axis_offset

        y_max = maximum([y_start; y_coords]) + axis_offset
        y_min = minimum([y_start; y_coords]) - axis_offset

        xlims!(axis, x_min, x_max)
        ylims!(axis, y_min, y_max)

        text_offset = 0.1

        scatter!(axis, x_start, y_start, markersize = 15, color = :red)
        scatter!(axis, x_coords, y_coords, markersize = 15, color = :blue)
        text!(axis, Point.(x_coords .+ text_offset, y_coords .+ text_offset), text = route_without_start)
        text!(axis, Point.(x_start + text_offset, y_start + text_offset), text = starting_city)

        # ---------------------- Sliders ----------------------
        sliders_array::Array{Any} = []

        for (key, value) in params["gui"]["sliders"]
            default_value = params["algorithm"]["params"][key]

            if isa(value[3], Float64)
                push!(
                    sliders_array, 
                    (label = key, range = value[1]:value[3]:value[2], startvalue = default_value, format = x -> string(round(100 * x, digits=3), " %"))
                )
            else
                push!(sliders_array, (label = key, range = value[1]:value[3]:value[2], startvalue = default_value))
            end
        end

        slider_objects = SliderGrid(slider_grid[1, 1],
            (label = "Step interval", range = 0:1:1000, format = x -> string(x, " ms")),
            sliders_array...
        )

        slider_labels = append!(["Step interval"], collect(keys(params["gui"]["sliders"])))
        slider_observables = [s.value for s in slider_objects.sliders]

        sliders = Dict{String, Union{Int, Float64}}(slider_labels .=> zeros(length(slider_labels)))

        for i in eachindex(slider_labels)
            if slider_labels[i] != "Step interval"
                sliders[slider_labels[i]] = params["algorithm"]["params"][slider_labels[i]]
            end

            on(slider_observables[i]) do value
                # println("New value of $(slider_labels[i]) is $value")
                sliders[slider_labels[i]] = value
                # println("$(sliders) == $value")
            end
        end

        # ---------------------- Buttons ----------------------
        button_labels = ["Play", "Pause", "Clear & Reset", "Step", "Default"]
        button_values = falses(length(button_labels))

        button_objects = [
            Button(button_grid[1, index], label = label)
            for (index, label) in enumerate(button_labels)
        ]

        buttons = Dict(button_labels .=> button_values)

        for i in eachindex(button_labels)
            on(button_objects[i].clicks) do click
                buttons[button_labels[i]] = true
                # println("New value of $(button_labels[i]) is $(buttons[button_labels[i]])")
            end
        end

        # ---------------------- Labels ----------------------
        label_labels = [
            "Current iteration: ", 
            "Current shortest distance: ", 
            "Current best: ", 
            "Best distance: ",
            "Best: "
        ]

        info_labels = [
            Label(best_label_grid[index, 1], label)
            for (index, label) in enumerate(label_labels)
        ]

        # ---------------------- Best Route ----------------------
        best_axis = Axis(best_axis_grid[1, 1], title = "Best route", xlabel = "x", ylabel = "y")

        xlims!(best_axis, x_min, x_max)
        ylims!(best_axis, y_min, y_max)

        scatter!(best_axis, x_start, y_start, markersize = 15, color = :red)
        scatter!(best_axis, x_coords, y_coords, markersize = 15, color = :blue)
        text!(best_axis, Point.(x_coords .+ text_offset, y_coords .+ text_offset), text = route_without_start)
        text!(best_axis, Point.(x_start + text_offset, y_start + text_offset), text = starting_city)

        sc = display(figure)

        graphics = MyGraphics(sliders, buttons, axis, nothing, best_axis_grid, best_axis, nothing, best_label_grid)

        new(params["cities"]["position"], nothing, graphics)
    end
end

function get_slider_values(gui::GUI)::Dict{String, Union{Int, Float64}}
    return gui.graphics.sliders
end

function get_button_values(gui::GUI)::Dict{String, Bool}
    return gui.graphics.buttons
end

function set_button_value(gui::GUI, button_label::String)
    gui.graphics.buttons[button_label] = false
end

function update_gui(gui::GUI, data::Dict{String, Any})
    ordered_cities = split(data["best"], "-")
    
    if !isnothing(gui.graphics.lines)
        delete!(gui.graphics.axis.scene, gui.graphics.lines)
    end

    x_coords = [gui.cities[label][1] for label in ordered_cities]
    y_coords = [gui.cities[label][2] for label in ordered_cities]

    gui.graphics.lines = lines!(gui.graphics.axis, x_coords, y_coords, color = :green)

    if isnothing(gui.best_entry) || data["distance"] < gui.best_entry["distance"]
        gui.best_entry = data

        if !isnothing(gui.graphics.best_lines)
            delete!(gui.graphics.best_axis.scene, gui.graphics.best_lines)
        end

        gui.graphics.best_lines = lines!(gui.graphics.best_axis, x_coords, y_coords, color = :green)
    end
end

end
