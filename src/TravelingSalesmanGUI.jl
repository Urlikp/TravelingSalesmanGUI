module TravelingSalesmanGUI

using JSON, GLMakie

include("Constants.jl")

export GUI, get_slider_value, get_button_value, set_button_value

mutable struct GUI
    sliders::Dict{String, Union{Int, Float64}}
    buttons::Dict{String, Bool}
    cities::Dict{String, Any}

    function GUI(params::Dict)
        set_theme!(theme_dark())
        figure = Figure(resolution = (height, width), title = "Traveling Salesman");

        figure[0, 1:2] = Label(figure, "Traveling Salesman", fontsize = 30)

        axis_grid = figure[1, 1] = GridLayout()
        button_grid = figure[2, 1:2] = GridLayout()
        slider_grid = figure[3, 1:2] = GridLayout()
        best_found_grid = figure[1, 2] = GridLayout()

        best_label_grid = best_found_grid[1, 1] = GridLayout()
        best_axis_grid = best_found_grid[1, 2] = GridLayout()

        axis = Axis(axis_grid[1, 1], title = "Current Route", xlabel = "x", ylabel = "y")
        x = collect(range(-10, stop=10, length = 20))
        y = x.^2

        push!(x, x[1])
        push!(y, y[1])

        scatterlines!(axis, x, y; markersize = 15)
        scatter!(axis, x[1], y[1], markersize = 15, color = :red)

        slider_objects = SliderGrid(slider_grid[1, 1],
            (label = "Step interval", range = 0:1:1000, format = x -> string(x, " ms")),
            (label = "Population size", range = 0:1:100),
            (label = "Crossover chance", range = 0:0.0001:1, format = x -> string(round(100 * x, digits=4), " %")),
            (label = "Elitism chance", range = 0:0.0001:1, format = x -> string(round(100 * x, digits=4), " %")),
            (label = "Mutation chance", range = 0:0.0001:1, format = x -> string(round(100 * x, digits=4), " %"))
        )

        slider_labels = ["Step", "Population", "Crossover", "Elitism", "Mutation"]
        slider_observables = [s.value for s in slider_objects.sliders]

        sliders = Dict{String, Union{Int, Float64}}(slider_labels .=> zeros(length(slider_labels)))

        for i in eachindex(slider_labels)
            on(slider_observables[i]) do value
                # println("New value of $(slider_labels[i]) is $value")
                sliders[slider_labels[i]] = value
                # println("$(sliders) == $value")
            end
        end

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

        best_axis = Axis(best_axis_grid[1, 1], title = "Best route", xlabel = "x", ylabel = "y")

        x = range(-10, stop=10, length = 20)
        y = abs.(x)
        scatterlines!(best_axis, x, y; markersize = 15)
        scatter!(best_axis, x[1], y[1], markersize = 15, color = :red)

        sc = display(figure);
        new(sliders, buttons, params["cities"])
    end
end

function get_slider_value(gui::GUI, slider_label::String)::Union{Int, Float64}
    return gui.sliders[slider_label]
end

function get_button_value(gui::GUI, button_label::String)::Bool
    return gui.buttons[button_label]
end

function set_button_value(gui::GUI, button_label::String)
    gui.buttons[button_label] = false
end

function update_route(gui::GUI, ordered_cities::Array{String}, distance::Float64)
    
end

end
