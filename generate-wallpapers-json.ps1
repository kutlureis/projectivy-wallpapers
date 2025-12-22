# SETTINGS
$repoUser = "kutlureis"
$repoName = "projectivy-wallpapers"
$branch = "main"
$imageFolder = "images"
$outputJson = "wallpapers.json"

# Folder with new images
$newImagesFolder = "D:\projectivy-launcher-github-wallpaper\new_images"

$baseUrl = "https://raw.githubusercontent.com/$repoUser/$repoName/$branch/$imageFolder"

# 1. Copy new images interactively
if (-Not (Test-Path $newImagesFolder)) {
    Write-Host "New images folder not found. Only existing images will be processed."
} else {
    $newImages = Get-ChildItem $newImagesFolder -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png|webp)$' } | Sort-Object Name
    foreach ($img in $newImages) {
        $answer = Read-Host "Do you want to add '$($img.Name)' to the repo images folder? (Y/N)"
        if ($answer -match '^[Yy]$') {
            Copy-Item $img.FullName -Destination $imageFolder -Force
            Write-Host "'$($img.Name)' copied."
        } else {
            Write-Host "'$($img.Name)' skipped."
        }
    }
}

# 2. Generate wallpapers.json
$images = Get-ChildItem $imageFolder -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png|webp)$' } | Sort-Object Name
$wallpapers = @()
foreach ($img in $images) {
    $wallpapers += @{ url = "$baseUrl/$($img.Name)" }
}

$json = @{ wallpapers = $wallpapers } | ConvertTo-Json -Depth 4
Set-Content -Encoding UTF8 $outputJson $json
Write-Host "wallpapers.json created or updated successfully ($($images.Count) images)"

# 3. Ask to push to GitHub
$pushAnswer = Read-Host "Do you want to push changes to GitHub? (Y/N)"
if ($pushAnswer -match '^[Yy]$') {
    git add .
    $commitMessage = "Update wallpapers and images - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git commit -m "$commitMessage"
    git push origin main
    Write-Host "Changes pushed to GitHub successfully."
} else {
    Write-Host "Push skipped."
}
