using Revise
using TravelingSalesmanGUI

params = Dict(
    "problem_name" => "problem01",
    "algorithm" => Dict(
        "name" => "GeneticAlgorithm",
        "params" => Dict(
            "population" => 30,
            "crossover" => 0.3,
            "elitism" => 0.15,
            "mutation" => 0.1
        )
    ),  
    "cities" => Dict(
        "a" => [1, 2],
        "b" => [4, 1],
        "c" => [1, 8],
        "d" => [14, 1],
        "e" => [4, 10],
        "f" => [6, 7],
        "g" => [8, 2],
        "h" => [9, 10]
    ),
    "gui" => Dict(
        "params" => Dict(
            "height" => 1920,
            "width" => 1080
        ),
        "sliders" => Dict(
            "population" => [0, 100, 1],
            "crossover" => [0, 1, 0.001],
            "elitism" => [0, 1, 0.001],
            "mutation" => [0, 1, 0.001]
        )
    )
)

test = GUI(params)

# for i in 1:5
#     println(test.sliders)
#     testovic = get_slider_value(test, "Step")
#     println("New value of Step is $testovic")
#     testik = get_button_value(test, "Play")
#     println("New value of Play is $testik")

#     if testik
#         set_button_value(test, "Play")
#         testik = get_button_value(test, "Play")
#         println("Change value of Play back to default ($testik)")
#     end

#     sleep(5)
# end