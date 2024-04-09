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

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/Base64Upgradeable.sol";


contract NFTUpgradeable is
    Initializable,
    ERC721Upgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    /****************************************************************************/
    /*                                  COUNTERS                                */
    /****************************************************************************/
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenId;

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

    struct NFT {
        uint id;
        uint classId;
        uint value;
        uint rarity;
    }

    // Use global struct to avoid "stack too deep" error from 16 local variable limit
    struct GlobalData {
        string classImageURI;
        mapping(uint => NFT) NFTs;
        mapping(uint => NFTClass) NFTClasses;
        mapping(address => uint[]) NFTsByOwner;
        mapping(uint => uint) TotalNFTsByClass;
    }    
    GlobalData public global;

    event NFTGranted(uint indexed tokenId, uint indexed classId, address indexed account, uint rarity, uint value);

    function initialize() public initializer {
        __ERC721_init("Vitruveo NFT", "VNFT");
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(GRANTER_ROLE, msg.sender);
        initClasses();
    }

    function initClasses() internal {
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

        NFT storage newNFT = global.NFTs[_tokenId.current()];
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

    function getTokenInfo(uint id) public view  returns (NFT memory)
    {
        return global.NFTs[id];
    }

    function getClassInfo(uint id) public view  returns (NFTClass memory)
    {
        return global.NFTClasses[id];
    }

    function tokenURI(uint tokenId) override public view returns (string memory){

        NFT memory nft = global.NFTs[tokenId];    
        require(nft.classId > 0, "Token ID does not exist");

        NFTClass memory nftClass = global.NFTClasses[nft.classId];

	    string memory json = Base64Upgradeable.encode(bytes(string(abi.encodePacked('{"name": "', nftClass.name, '", "description": "Vitruveo NFT", "image": "', global.classImageURI, nftClass.id, '.png"}'))));
	
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

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    // The following functions are overrides required by Solidity.

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}

