# src/wind_rose_plot.jl

#Wind Rose Plotting for Wind Farm Optimization
#Uses WindFarmModule for data loading consistency
#You can use the "include("your_JSON_file")" to use general data without modules 

using PyPlot
include("WindFarmModule.jl")
using .WindFarmModule
"""
    plot_wind_rose_from_data(wind_data::WindInput)

Create a wind rose plot with red (high freq) to blue (low freq) colors
"""
function plot_wind_rose_from_data(wind_data::WindFarmModule.WindInput)
    
    println("🌹 Creating Wind Rose Plot...")
    
    PyPlot.clf()  # Clear the current figure
    PyPlot.close("all")  # Close all previous figures

    
    # Convert wind directions to radians for polar plot
    theta_deg = wind_data.bins
    theta_rad = deg2rad.(theta_deg)
    frequencies = wind_data.freq
    
    # Calculate bar width (assuming evenly spaced directions)
    n_dirs = length(theta_deg)
    width = 2π / n_dirs  # Width of each bar in radians
    
    println("   Wind directions: $(n_dirs) bins")
    println("   Frequency range: $(round(minimum(frequencies)*100, digits=1))% - $(round(maximum(frequencies)*100, digits=1))%")

    ##  Professional Wind Rose  ##

    fig = figure("wind_rose_professional", figsize=(10, 10))
    ax = PyPlot.axes(polar=true)
    
    # Create color-coded bars: RED (high freq) to BLUE (low freq)
    cmap = PyPlot.cm.RdBu_r  # Red-Blue reversed (Red=high, Blue=low)
    norm = PyPlot.matplotlib.colors.Normalize(vmin=minimum(frequencies), vmax=maximum(frequencies))
    colors = [cmap(norm(freq)) for freq in frequencies]
    
    # Create bar plot with color-coded frequencies
    bars = bar(theta_rad, frequencies, width=width, 
               color=colors, edgecolor="black", linewidth=1.0, alpha=0.9)
    
    # Formatting
    ax.set_title("Wind Rose - Directional Frequency Distribution\nWind Speed: $(wind_data.speed) m/s", 
                 fontsize=14, fontweight="bold", pad=20)
    
    # Set grid lines every 22.5 degrees (16 directions)
    dtheta = 22.5
    ax.set_thetagrids(collect(0:dtheta:360-dtheta), 
                      ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", 
                       "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"])
    
    # Set radial grid (frequency percentages)
    max_freq = maximum(frequencies)
    ax.set_ylim(0, max_freq * 1.1)
    
    # Create better radial ticks
    n_ticks = 5
    tick_values = collect(range(0, max_freq, length=n_ticks+1))[2:end]
    ax.set_rticks(tick_values)
    ax.set_rlabel_position(45)  # Position radial labels
    
    # Wind conventions
    ax.set_theta_zero_location("N")  # North at top
    ax.set_theta_direction(-1)       # Clockwise (meteorological convention)
    
    # Create a proper colorbar using ScalarMappable
    sm = PyPlot.matplotlib.cm.ScalarMappable(cmap=cmap, norm=norm)
    sm.set_array([])  # Required for matplotlib
    cbar = colorbar(sm, ax=ax, shrink=0.8, pad=0.1)
    cbar.set_label("Wind Frequency", fontsize=12)
    
    # Add text with wind statistics below the plot
    textstr = """Total Directions: $(n_dirs)  |  Avg Wind Speed: $(wind_data.speed) m/s  |  Turbulence Intensity: $(round(wind_data.ti*100, digits=1))%  |  Dominant Direction: $(theta_deg[argmax(frequencies)])°  |  Max Frequency: $(round(maximum(frequencies)*100, digits=1))%"""
        
    # Add text box below the plot
    props = Dict("boxstyle" => "round,pad=0.8", "facecolor" => "lightgray", "alpha" => 0.9, "edgecolor" => "black")
    ax.text(0.5, -0.15, textstr, transform=ax.transAxes, fontsize=10,
        verticalalignment="top", horizontalalignment="center", bbox=props)

    # Save the plot
    if !isdir("results")
        mkpath("results")
    end
    
    savefig("results/wind_rose_plot.png", dpi=300, bbox_inches="tight")
    println("   Wind rose saved to: results/wind_rose_plot.png")
    println("   🔴 Red bars = High frequency directions")
    println("   🔵 Blue bars = Low frequency directions")
    
    # Display the plot
    show()
    
    return fig
end

function create_wind_rose()
    # Load wind data using WindFarmModule 
    wind_data = WindFarmModule.load_wind_input("data/wind_input.json")
    
    # Create wind rose plot
    fig = plot_wind_rose_from_data(wind_data)
    
    return fig
end
# Export main function
export create_wind_rose, plot_wind_rose_from_data


println("🌹 Auto-generating wind rose...")
create_wind_rose()
