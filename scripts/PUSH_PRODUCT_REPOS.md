# Push all After OS product repos

`gh` must be authenticated once:

```powershell
& "$env:LOCALAPPDATA\gh-cli\bin\gh.exe" auth login --hostname github.com --git-protocol https --web
```

Then create + push every catalog product scaffold:

```powershell
cd D:\Projects\HANTURAI\supercore
pwsh .\scripts\create_product_repos.ps1
```

Dry run:

```powershell
pwsh .\scripts\create_product_repos.ps1 -DryRun
```

This creates private `oversteintech/<folder>` repos for every entry in `catalog/products.yaml` that is not `supercore` / `supergarage`, and pushes the local `main` branch.
