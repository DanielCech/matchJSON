matchJSON
=========

OS X command line tool for structure comparison of JSON files. Compares two JSONs and shows differences regardless string/number values. It can be used for testing if API JSON response matches API specification.

#### Usage

    $ ./matchJSON <parameters> <file1.json> <file2.json>
    
#### Parameters

| Parameter | Meaning |
| --- | --- |
| -n | allow null on one side                            |
| -a | allow empty array on one side                     |
| -d | allow empty dictionary on one side                |
| -f | compare all array items of file1 with first array item of file2                |

#### Example

    $ ./matchJSON -a -n /Users/dan/Dropbox/Public/JSON/file1.json /Users/dan/Dropbox/Public/JSON/file2.json
    
    [<] prices/0/parts/0/cards/0/cardNumber: missing key
    [!] prices/0/parts/0/cards/1/cardStatus: type mismatch - [<]: string, [>]: number
    [>] prices/0/parts/0/cards/2/auctionBegin: missing key
    [>] prices/0/parts/0/cards/2/auctionEnd: missing key
    [<] prices/0/parts/0/cards/2/avatar: missing key
    [>] prices/0/parts/0/cards/2/avatarURL: missing key
    [!] prices/0/parts/0/numCards: type mismatch - [<]: number, [>]: boolean
    [!] prices/0/priceId: type mismatch - [<]: number, [>]: string
    
Demo [file1.json](https://dl.dropboxusercontent.com/u/57198916/JSON/file1.json), [file2.json](https://dl.dropboxusercontent.com/u/57198916/JSON/file2.json)

#### Legend

    [<] first file
    [>] second file

#### Binary

You can download binary [here](https://dl.dropboxusercontent.com/u/57198916/JSON/matchJSON).
