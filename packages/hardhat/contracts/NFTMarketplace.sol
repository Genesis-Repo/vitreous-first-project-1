// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;
    
    struct Item {
        uint256 id;
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool sold;
    }
    
    mapping(uint256 => Item) private items;

    event ItemListed(uint256 indexed id, address indexed seller, address indexed nftContract, uint256 tokenId, uint256 price);
    event ItemSold(uint256 indexed id, address indexed buyer, uint256 price);

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function listNFT(address _nftContract, uint256 _tokenId, uint256 _price) external {
        require(_price > 0, "Price must be greater than 0");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        items[itemId] = Item(itemId, msg.sender, _nftContract, _tokenId, _price, false);

        emit ItemListed(itemId, msg.sender, _nftContract, _tokenId, _price);
    }

    function buyNFT(uint256 _itemId) external payable {
        Item storage item = items[_itemId];

        require(item.id != 0, "Item not listed");
        require(!item.sold, "Item already sold");
        require(msg.value >= item.price, "Insufficient payment");

        item.sold = true;
        _itemsSold.increment();

        safeTransferFrom(item.seller, msg.sender, item.tokenId);

        emit ItemSold(_itemId, msg.sender, item.price);
    }

    function getItem(uint256 _itemId) external view returns (uint256 id, address seller, address nftContract, uint256 tokenId, uint256 price, bool sold) {
        Item storage item = items[_itemId];
        return (item.id, item.seller, item.nftContract, item.tokenId, item.price, item.sold);
    }

    function totalItems() external view returns (uint256) {
        return _itemIds.current();
    }

    function totalItemsSold() external view returns (uint256) {
        return _itemsSold.current();
    }
}