param([string]$rootPath = "c:\xampp\htdocs\fnff")
$files = Get-ChildItem -Path $rootPath -Recurse -Filter "index.html"


foreach ($file in $files) {
    Write-Host "Processing: $($file.FullName)"
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8

    $modified = $false

    # 1. Header Replacement
    # Matches the "App" dropdown and captures the relative prefix from the Bloodlink link
    $headerRegex = '(?s)<li class="navbar__item navbar__item--has-children nav-fade">\s*<a href="#" aria-label="dropdown menu"\s*class="navbar__dropdown-label dropdown-label-alter">App</a>\s*<ul class="navbar__sub-menu">\s*<li><a href="([^"]*)bloodlink/">Bloodlink</a></li>\s*<li><a href="https://portal-lime-iota.vercel.app/" target="_blank">Portal</a></li>\s*</ul>\s*</li>'
    
    if ($content -match $headerRegex) {
        $prefix = $matches[1]
        $newHeaderBlock = @"
<li class="navbar__item nav-fade">
                        <a href="${prefix}bloodlink/">Bloodlink</a>
                      </li>
                      <li class="navbar__item nav-fade">
                        <a href="https://portal-lime-iota.vercel.app/" target="_blank">Portal</a>
                      </li>
"@
        $content = $content -replace $headerRegex, $newHeaderBlock
        $modified = $true
        Write-Host "  - Header updated"
    }

    # 2. Footer Replacement
    # Matches the "Shop" link and appends Bloodlink and Portal if not already present
    # Using a lookahead to ensure we don't duplicate if Bloodlink is already there
    $footerRegex = '(?s)(<li><a href="([^"]*)shop/"><i class="fa-solid fa-arrow-right"></i>Shop</a></li>)(?!\s*<li><a href="[^"]*bloodlink/)'
    
    if ($content -match $footerRegex) {
        $shopLine = $matches[1]
        $prefix = $matches[2]
        $newFooterItems = @"
$shopLine
                  <li><a href="${prefix}bloodlink/"><i class="fa-solid fa-arrow-right"></i>Bloodlink</a></li>
                  <li><a href="https://portal-lime-iota.vercel.app/" target="_blank"><i class="fa-solid fa-arrow-right"></i>Portal</a></li>
"@
        # Note: -replace matches the regex. Since we captured the shop line in Group 1, we can just replace the whole match.
        # But $matches only contains the first match details. Using -replace with Regex object logic is safer or just -replace operator.
        # Powershell -replace operator replaces ALL occurrences.
        # We need to be careful. The Regex includes the lookahead. The lookahead is zero-width assertion, so it won't be replaced.
        # Wait, -replace replaces what matches. The lookahead is NOT part of the match? 
        # Actually positive lookahead (?=...) is zero width. Negative lookahead (?!...) matches if NOT followed.
        # So the match IS the Shop line.
        # So we replace the Shop line with Shop line + New items.
        
        $content = $content -replace $footerRegex, $newFooterItems
        $modified = $true
        Write-Host "  - Footer updated"
    }

    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "  - Saved"
    }
}
