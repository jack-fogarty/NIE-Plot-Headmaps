# NIE-Plot-Headmaps
A simple flexible app to plot EEG and fNIRS* topography.
<br>
_*fNIRS plots are currently compatible with Brite24 data only._


# Prerequisites
1. Matlab
2. Fieldtrip Toolbox
3. EEGLAB

# Input data
Users should have topographical data in an Excel file, where:
   - The first row has column headers featuring the correct channel labels (Headmap_Title, Channel_1, Channel_2, Channel_3, etc)
   - The first column should contain the Headmap titles with each row reserved for a new headmap/plot (e.g., Factor_1, Factor_2, etc)
   - All other columns should contain data (e.g., amplitude) for the given channel
   - Channel names listed in the header should match the channel location file for the given data
Users will need a channel location file for EEG data (e.g., a **.ced** file); this can can be made in programs such as EEGLAB

# Usage
1. Browse to the Excel file containing topographical data
2. Select the correct tab in the Excel Tab dropdown
3. Click "Load"
4. Select export parameters (e.g., change colormap, limits, resolution)
5. Use "Test" to get a glimpse of what the headmap may look like
6. Use "Generate" to output headmaps
7. Load your channel location file when prompted and headmaps will be generated in the location of the input file

![NIE_plot_headmap_GUI](https://github.com/user-attachments/assets/9c7d86d9-d539-4f0e-a84c-59671a0147fc)
