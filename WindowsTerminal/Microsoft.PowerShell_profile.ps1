################################################################################
#                                Initial Commands                              #
################################################################################

Clear-Host;
$PSStyle.FileInfo.Directory = "[33m"

################################################################################
#                                  Oh my Posh!                                 #
################################################################################

# Import-Module "oh-my-posh";
Import-Module "posh-git";
# Import-Module "Terminal-Icons";
Import-Module "PSReadLine";
# Set-PoshPrompt -Theme "$Env:LOCALAPPDATA\kali.theme.json";
oh-my-posh init pwsh --config "$Env:LOCALAPPDATA\kali.theme.json" | Invoke-Expression

################################################################################
#                                  PSReadLine                                  #
################################################################################

Set-PSReadlineOption -BellStyle "None";
Set-PSReadLineOption -PredictionSource "History";
Set-PSReadLineKeyHandler -Chord "Tab" -Function "MenuComplete";

Set-PSReadLineOption -Colors @{
  "InlinePrediction" = [ConsoleColor]::DarkGray;
}