// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol"; 


contract MyToken is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyToken", "MTK") {}
    
    uint256 MAX_SUPPLY = 3;

    string[] UrisIpfs = [
        "https://ipfs.io/ipfs/QmTv7MSGURjZhqAQtib9Vvk2JX35URtpbpPhVwQyV6KxGj",
        "https://ipfs.io/ipfs/Qme35F8z7SQRc3nHY1DZNrwsaQmixURUnWh2UkPTFRtEjj",
        "https://ipfs.io/ipfs/QmUVFK8HbStrB9YFH2spHxFGWdQFbCtYrsxui1vYjRBnvt"
    ];

    string[] characteristic = [
        "Murderer",
        "Murdered",
        "Murdering"
    ];

    function safeMint(address to) public {
        // Current counter value will be the minted token's token ID.
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId <= MAX_SUPPLY, "Plus de tokens disponibles" );
        // Increment it so next time it's correct when we call .current()
        _tokenIdCounter.increment();
        // Mint the token
        _safeMint(to, tokenId);
        // select the Uri
        string memory itemUri = getTokenURI(tokenId);
        //add it to the token
        _setTokenURI(tokenId, itemUri);
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "#', Strings.toString(tokenId), '",',
                '"description": "',characteristic[tokenId],'",',
                '"image": "', UrisIpfs[tokenId], '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }


    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}