matchJSON
=========

OS X commandline tool for structure comparison of two JSON files

#### Usage:

    $ ./matchJSON <parameters> <file1.json> <file2.json>
    
#### Parameters:

| Parameter | Meaning |
| --- | --- |
| -n | allow null on one side                            |
| -a | allow empty array on one side                     |
| -d | allow empty dictionary on one side                |
| -f | compare just first items of arrays                |
| -m | compare array items mutually (not working, under construction) |

#### Example:

    $ ./matchJSON -a -n /Users/dan/Dropbox/Public/JSON/file1.json /Users/dan/Dropbox/Public/JSON/file2.json
    
    [<] prices/0/parts/0/cards/0/cardNumber: missing key
    [!] prices/0/parts/0/cards/1/cardStatus: type mismatch - [<]: __NSCFString, [>]: __NSCFNumber
    [>] prices/0/parts/0/cards/2/auctionBegin: missing key
    [>] prices/0/parts/0/cards/2/auctionEnd: missing key
    [<] prices/0/parts/0/cards/2/avatar: missing key
    [>] prices/0/parts/0/cards/2/avatarURL: missing key
    [!] prices/0/priceId: type mismatch - [<]: __NSCFNumber, [>]: __NSCFConstantString
    
Demo [file1.json](https://dl.dropboxusercontent.com/u/57198916/JSON/file1.json), [file2.json](https://dl.dropboxusercontent.com/u/57198916/JSON/file2.json)

#### Legend

    [<] first file
    [>] second file

#### Binary

You can download binary [here](https://dl.dropboxusercontent.com/u/57198916/JSON/matchJSON).
