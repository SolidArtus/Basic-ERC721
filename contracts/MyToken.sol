// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyToken is ERC721, ERC721Burnable, Ownable, ERC721URIStorage {
    constructor() ERC721("MyToken", "MTK") {}

    uint256 MAX_SUPPLY = 6;

    function safeMint(address to) public {
        // Le compteur vérifie le numéro de jeton actuel
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId <= MAX_SUPPLY, "Plus de tokens disponibles" );
        // On l'incrémente pour le prochain jeton 
        _tokenIdCounter.increment();
        // Il créé le token, en appelant la fonction _safeMint
        _safeMint(to, tokenId);
        // select the Uri
        string memory itemUri = getTokenURI(tokenId);
        //add it to the token
        _setTokenURI(tokenId, itemUri);
    }

    function getTokenURI(uint256 tokenId) public pure returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "#', Strings.toString(tokenId), '",',
                '"description": "Ceci est un NFT de ma nouvelle collection !",',
                '"image": "https://ipfs.io/ipfs/QmQeHsZjRuH4hGHGUojH5JeVUZXdyBxPGCuAG52EZSbBZ5/' , Strings.toString(tokenId), '.jpg"',
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
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

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
