#Requires -Version 7.0

<#
.SYNOPSIS
    Evaluates Terraform plan JSON using OPA and generates reusable
    machine-readable security assurance evidence.

.DESCRIPTION
    Cross-Framework Continuous Security Assurance Project

    Build Once. Validate Continuously. Demonstrate Across Frameworks.

    This script evaluates proposed infrastructure configurations
    against Rego policies and generates standardized JSON evidence
    containing validation results and evidence provenance.

    No AWS resources are created or modified.

.NOTES
    Exit codes:
        0 = Validation passed
        1 = Validation denied
        2 = Execution or evidence generation error
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$InputPath,

    [Parameter(Mandatory)]
    [string]$PolicyPath,

    [Parameter(Mandatory)]
    [string]$OutputPath,

    [Parameter(Mandatory)]
    [ValidateSet(
        "terraform_plan_validation",
        "simulated_negative_test"
    )]
    [string]$EvidenceType,

    [string]$PolicyQuery = "data.terraform.aws.ec2.report"
)

$ErrorActionPreference = "Stop"

try {

    # --------------------------------------------------------
    # Validate required files and tools
    # --------------------------------------------------------

    $inputFile = Get-Item -LiteralPath $InputPath
    $policyFile = Get-Item -LiteralPath $PolicyPath

    if ($inputFile.PSIsContainer -or $policyFile.PSIsContainer) {
        throw "Input and policy paths must identify files."
    }

    $resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)

    if ($resolvedOutput -eq $inputFile.FullName -or
        $resolvedOutput -eq $policyFile.FullName) {
        throw "Output must not overwrite the input or policy."
    }

    Get-Command opa -ErrorAction Stop | Out-Null

    # --------------------------------------------------------
    # Identify tool and input versions
    # --------------------------------------------------------

    $plan = Get-Content -LiteralPath $inputFile.FullName -Raw |
        ConvertFrom-Json

    $opaVersionOutput = opa version

    if ($LASTEXITCODE -ne 0) {
        throw "Unable to identify OPA version."
    }

    $opaVersion = $opaVersionOutput |
        Where-Object { $_ -match "^Version:" } |
        Select-Object -First 1

    if (-not $opaVersion) {
        throw "OPA version was not found."
    }

    $opaVersion = ($opaVersion -replace "^Version:\s*", "").Trim()

    # --------------------------------------------------------
    # Capture input and policy fingerprints
    # --------------------------------------------------------

    $inputHash = (
        Get-FileHash `
            -LiteralPath $inputFile.FullName `
            -Algorithm SHA256
    ).Hash.ToLowerInvariant()

    $policyHash = (
        Get-FileHash `
            -LiteralPath $policyFile.FullName `
            -Algorithm SHA256
    ).Hash.ToLowerInvariant()

    # --------------------------------------------------------
    # Compile the Rego policy
    # --------------------------------------------------------

    opa check --strict $policyFile.FullName

    if ($LASTEXITCODE -ne 0) {
        throw "Rego policy compilation failed."
    }

    # --------------------------------------------------------
    # Execute the security policy evaluation
    # --------------------------------------------------------

    $evaluation = opa eval `
        --format json `
        --fail `
        --data $policyFile.FullName `
        --input $inputFile.FullName `
        $PolicyQuery

    if ($LASTEXITCODE -ne 0) {
        throw "OPA policy evaluation failed."
    }

    $opaResult = ($evaluation -join "`n") |
        ConvertFrom-Json

    $resultSets = @($opaResult.result)

    if ($resultSets.Count -ne 1) {
        throw "Expected exactly one OPA evaluation result."
    }

    $expressions = @($resultSets[0].expressions)

    if ($expressions.Count -ne 1) {
        throw "Expected exactly one policy report."
    }

    $validation = $expressions[0].value

    # --------------------------------------------------------
    # Validate the policy report structure
    # --------------------------------------------------------

    if ($null -eq $validation -or
        $validation.allow -isnot [bool] -or
        $validation.status -notin @(
            "PASS",
            "FAIL",
            "INVALID_INPUT",
            "NOT_APPLICABLE"
        ) -or
        $null -eq $validation.summary -or
        $null -eq $validation.results) {

        throw "OPA returned an invalid validation report."
    }

    if ($validation.allow -ne ($validation.status -eq "PASS")) {
        throw "Inconsistent policy decision."
    }

    # --------------------------------------------------------
    # Confirm input and policy did not change during evaluation
    # --------------------------------------------------------

    $currentInputHash = (
        Get-FileHash `
            -LiteralPath $inputFile.FullName `
            -Algorithm SHA256
    ).Hash.ToLowerInvariant()

    $currentPolicyHash = (
        Get-FileHash `
            -LiteralPath $policyFile.FullName `
            -Algorithm SHA256
    ).Hash.ToLowerInvariant()

    if ($currentInputHash -ne $inputHash -or
        $currentPolicyHash -ne $policyHash) {
        throw "Input or policy changed during evaluation."
    }

    # --------------------------------------------------------
    # Classify the evidence
    # --------------------------------------------------------

    $description = switch ($EvidenceType) {

        "terraform_plan_validation" {
            "Validation of proposed infrastructure configuration. " +
            "Does not establish deployed-state compliance."
        }

        "simulated_negative_test" {
            "Simulated noncompliant configuration used to verify " +
            "policy detection capabilities. Not an actual AWS finding."
        }
    }

    # --------------------------------------------------------
    # Build the standardized evidence artifact
    # --------------------------------------------------------

    $evidence = [ordered]@{
        schema_version = "1.0"

        project = "Cross-Framework Continuous Security Assurance"

        evidence_type = $EvidenceType

        evidence_description = $description

        generated_at_utc = [DateTime]::UtcNow.ToString("o")

        tools = [ordered]@{
            terraform_version = $plan.terraform_version
            terraform_plan_format = $plan.format_version
            opa_version = $opaVersion
        }

        provenance = [ordered]@{
            input = [ordered]@{
                filename = $inputFile.Name
                sha256 = $inputHash
            }

            policy = [ordered]@{
                filename = $policyFile.Name
                sha256 = $policyHash
                query = $PolicyQuery
            }
        }

        validation = $validation
    }

    # --------------------------------------------------------
    # Generate the machine-readable evidence file
    # --------------------------------------------------------

    $outputDirectory = Split-Path -Parent $resolvedOutput

    if (-not (Test-Path -LiteralPath $outputDirectory)) {
        throw "Evidence output directory does not exist."
    }

# Generate consistent UTF-8 JSON with LF line endings
# regardless of the operating system.

$evidenceJson = $evidence | ConvertTo-Json -Depth 100

$evidenceJson = $evidenceJson.Replace("`r`n", "`n").Replace("`r", "`n")

[System.IO.File]::WriteAllText(
    $resolvedOutput,
    ($evidenceJson + "`n"),
    [System.Text.UTF8Encoding]::new($false)
)

    # --------------------------------------------------------
    # Display the validation decision
    # --------------------------------------------------------

    Write-Host ""
    Write-Host "Security Validation Results"
    Write-Host "---------------------------"
    Write-Host "Evidence type: $EvidenceType"
    Write-Host "OPA version:   $opaVersion"
    Write-Host "Status:        $($validation.status)"
    Write-Host "Allow:         $($validation.allow)"
    Write-Host "Total checks:  $($validation.summary.total)"
    Write-Host "Passed:        $($validation.summary.passed)"
    Write-Host "Failed:        $($validation.summary.failed)"
    Write-Host "Indeterminate: $($validation.summary.indeterminate)"
    Write-Host ""
    Write-Host "Evidence saved to:"
    Write-Host $resolvedOutput
    Write-Host ""

    if ($validation.allow -eq $true) {
        Write-Host "VALIDATION PASSED" -ForegroundColor Green
        exit 0
    }

    Write-Host "VALIDATION DENIED" -ForegroundColor Red
    exit 1
}
catch {
    Write-Host ""
    Write-Host "EXECUTION ERROR" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 2
}
