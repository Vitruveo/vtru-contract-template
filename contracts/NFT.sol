/*
 *
 *
 *   ██╗   ██╗    ██╗    ████████╗    ██████╗     ██╗   ██╗    ██╗   ██╗    ███████╗     ██████╗ 
 *   ██║   ██║    ██║    ╚══██╔══╝    ██╔══██╗    ██║   ██║    ██║   ██║    ██╔════╝    ██╔═══██╗
 *   ██║   ██║    ██║       ██║       ██████╔╝    ██║   ██║    ██║   ██║    █████╗      ██║   ██║
 *   ╚██╗ ██╔╝    ██║       ██║       ██╔══██╗    ██║   ██║    ╚██╗ ██╔╝    ██╔══╝      ██║   ██║
 *    ╚████╔╝     ██║       ██║       ██║  ██║    ╚██████╔╝     ╚████╔╝     ███████╗    ╚██████╔╝
 *     ╚═══╝      ╚═╝       ╚═╝       ╚═╝  ╚═╝     ╚═════╝       ╚═══╝      ╚══════╝     ╚═════╝ 
 * 
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract NFT is
    ERC721,
    Pausable,
    AccessControl
{
    /****************************************************************************/
    /*                                  COUNTERS                                */
    /****************************************************************************/
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;

    uint public constant DECIMALS = 10 ** 18;

    /****************************************************************************/
    /*                                  ROLES                                   */
    /****************************************************************************/
    bytes32 public constant GRANTER_ROLE = bytes32(uint(0x01));
    bytes32 public constant UPGRADER_ROLE = bytes32(uint(0x02));

    /****************************************************************************/
    /*                                 TOKENS                                   */
    /****************************************************************************/

    struct NFTClass {
        uint id;
        string  name; 
        uint value;
    }

    struct NFTInfo {
        uint id;
        uint classId;
        uint value;
        uint rarity;
    }

    // Use global struct to avoid "stack too deep" error from 16 local variable limit
    struct GlobalData {
        string classImageURI;
        mapping(uint => NFTInfo) NFTs;
        mapping(uint => NFTClass) NFTClasses;
        mapping(address => uint[]) NFTsByOwner;
        mapping(uint => uint) TotalNFTsByClass;
    }    
    GlobalData public global;

    event NFTGranted(uint indexed tokenId, uint indexed classId, address indexed account, uint rarity, uint value);

    constructor() ERC721("Vitruveo NFT", "VNFT") {

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(GRANTER_ROLE, msg.sender);

        global.classImageURI = "https://nftstorage.link/ipfs/bafybeiaf3dswl2dk7nrbm7itetpoclzgzbj25frof3nsj2mjmac623dbea/";

        registerNFTClass(1, "Common", 100);
        registerNFTClass(2, "Rare", 200);
        registerNFTClass(3, "Ultra", 300);
    }

    function grantNFT(
        uint classId,
        address account,
        uint rarity
    ) public onlyRole(GRANTER_ROLE) whenNotPaused {

        NFTClass memory nftClass = global.NFTClasses[classId];

        require(
            nftClass.value > 0, 
            "Specified token class not active."
        );

        require(
            rarity >= 1 && rarity <= 10,
            "Rarity range 1-10"
        );

        _tokenId.increment();

        NFTInfo storage newNFT = global.NFTs[_tokenId.current()];
        newNFT.id = _tokenId.current();
        newNFT.classId = classId;
        newNFT.value = nftClass.value;
        newNFT.rarity = rarity;

        global.NFTsByOwner[account].push(newNFT.id); 
        global.TotalNFTsByClass[classId]++;

        _mint(account, newNFT.id);

        emit NFTGranted(newNFT.id, classId, account, rarity, nftClass.value);        
    }

    function getAccountTokens(address account) public view returns(uint[] memory){

       return global.NFTsByOwner[account];
    }

    function getTokenInfo(uint id) public view  returns (NFTInfo memory)
    {
        return global.NFTs[id];
    }

    function getClassInfo(uint id) public view  returns (NFTClass memory)
    {
        return global.NFTClasses[id];
    }

    function tokenURI(uint tokenId) override public view returns (string memory){

        NFTInfo memory nft = global.NFTs[tokenId];    
        require(nft.classId > 0, "Token ID does not exist");

        NFTClass memory nftClass = global.NFTClasses[nft.classId];

	    string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', nftClass.name, '", "description": "Vitruveo NFT", "image": "', global.classImageURI, nftClass.id, '.png"}'))));
	
        return string(abi.encodePacked('data:application/json;base64,', json));
    }

    function currentSupply() public view returns (uint) {
        return _tokenId.current();
    }

    function registerNFTClass(
        uint id,
        string memory name,
        uint value
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused returns (NFTClass memory) {

        global.NFTClasses[id] = NFTClass(id, name, value);
  
        return global.NFTClasses[id];
    }

    function setClassImageURI(string memory uri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        global.classImageURI = uri;
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function recoverVTRU() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(payable(msg.sender).send(address(this).balance));
    }

    receive() external payable {
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}

