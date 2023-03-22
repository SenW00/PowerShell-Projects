#Begin Random Password Function

Function NewSRP {
 
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(2,20)]
        [int]   $WordCount = 2,
 
        [Parameter(Mandatory = $false)]
        [string]  $WordListFilePath
     )
 
    BEGIN {
        $SpecialCharacters = @((33,35) + (36..38) + (42) + (61,63) + (64))
        $Numbers = @(48..57)
    }
 
    PROCESS {
        try {
            if ($PSBoundParameters.ContainsKey('WordListFilePath')) {
                if ((Test-Path $WordListFilePath) -and
                    ((Get-Item $WordListFilePath | select -ExpandProperty Extension) -eq '.txt')) {
                      $FullList = Get-Content $WordListFilePath
                } 
            }
 
            #If the local wordlist was not found or the file was not a txt file, grab a wordlist online
            if (-not $FullList) {
                $Site = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/theSysadminChannel/Wordlists/master/WordList'
                $FullList = $Site.Content.Trim().split("`n")
            }
                 
            [System.Collections.ArrayList]$3LtrWord = @()
            [System.Collections.ArrayList]$4LtrWord = @()
            [System.Collections.ArrayList]$5LtrWord = @()
            [System.Collections.ArrayList]$6LtrWord = @()
            [System.Collections.ArrayList]$7LtrWord = @()
            [System.Collections.ArrayList]$8LtrWord = @()
            [System.Collections.ArrayList]$9LtrWord = @()
 
            #Separating words into different arrays.
            foreach ($Word in $FullList) {
                switch ($word.Length) {
                    3 {$3LtrWord.Add($Word) | Out-Null}
                    4 {$4LtrWord.Add($Word) | Out-Null}
                    5 {$5LtrWord.Add($Word) | Out-Null}
                    6 {$6LtrWord.Add($Word) | Out-Null}
                    7 {$7LtrWord.Add($Word) | Out-Null}
                    8 {$8LtrWord.Add($Word) | Out-Null}
                    9 {$9LtrWord.Add($Word) | Out-Null}
                }
            }
 
            #Minimum 14 character password if we remove spaces and special characters
            switch ($WordCount) {
                2 {$WordList = $7LtrWord + $8LtrWord}
                3 {$WordList = $4LtrWord + $5LtrWord + $6LtrWord}
                4 {$WordList = $4LtrWord + $5LtrWord + $6LtrWord + $7LtrWord}
                5 {$WordList = $4LtrWord + $5LtrWord + $6LtrWord}
                6 {$WordList = $3LtrWord + $4LtrWord + $5LtrWord}
            }

            $CharNum = Get-Random -InputObject @([bool]$True, [bool]$False)
            
            $Password = 1..$WordCount | ForEach-Object {
                if($CharNum){
                        ($WordList | Get-Random -Count 1) + 
                        ([char]($SpecialCharacters | Get-Random -Count 1))
                    }else{ 
                        ($WordList | Get-Random -Count 1) + 
                        ([char]($Numbers | Get-Random -Count 1))
                    }
                    $CharNum = !$CharNum
                }
                        
           ($Password -as [string]).Replace(' ','')
            
 
        } catch { Write-Error $_.Exception.Message }
    }
 
    END {}
 }#End Random Password Function
