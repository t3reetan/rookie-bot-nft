// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract RookieBots is ERC721Enumerable, Ownable {
    /**
     * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`.
     * tokenURI is basically the token's metadata, which usually resolves to JSON (see browser bookmark for more info)
     */
    string _baseTokenURI;

    //  _presalePrice is the price of one Rookie Bot NFT
    uint256 public _presalePrice = 0.01 ether;

    //  _publicPrice is the price of one Rookie Bot NFT
    uint256 public _publicPrice = 0.05 ether;

    // _paused is used to pause the contract in case of an emergency
    bool public _paused;

    // max number of Rookie Bots
    uint256 public maxTokenIds = 5;

    // total number of tokenIds minted
    uint256 public tokenIds;

    // Whitelist contract instance
    IWhitelist whitelist;

    // boolean to keep track of whether presale started or not
    bool public presaleStarted;

    // timestamp for when presale would end
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract currently paused");
        _; // the function body of the function using this modifer is inserted here e.g. presaleMint() below
    }

    /**
     * @dev ERC721 constructor takes in a `name` and a `symbol` to the token collection.
     * name in our case is `Rookie Bots` and symbol is `RB`.
     * Constructor for Rookie Bots takes in the baseURI to set _baseTokenURI for the collection.
     * It also initializes an instance of whitelist interface.
     */
    constructor(string memory baseURI, address whitelistContract)
        ERC721("Rookie Bots", "RB")
    {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    /**
     * @dev startPresale starts a presale for the whitelisted addresses
     * onlyOwner modifier ensures that only the owner is able to start the presale
     */
    function startPresale() public onlyOwner {
        presaleStarted = true;
        // Set presaleEnded time as current timestamp + 5 minutes
        // Solidity has cool syntax for timestamps (seconds, minutes, hours, days, years)
        presaleEnded = block.timestamp + 30 minutes;
    }

    /**
     * @dev presaleMint allows a user to mint one NFT per transaction during the presale.
     */
    function presaleMint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp < presaleEnded,
            "Presale is not running"
        );
        require(
            whitelist.whitelistedAddresses(msg.sender),
            "You are not whitelisted"
        );
        require(
            tokenIds < maxTokenIds,
            "Exceeded maximum Rookie Bots supply. Collection is fully minted."
        );
        require(msg.value >= _presalePrice, "Ether sent is not correct");
        tokenIds += 1;
        // _safeMint(ERC721 function) is a safer version of the _mint function as it ensures that
        // if the address being minted to is a contract, it is able receive/deal with ERC721 tokens, otherwise transfer is reverted
        // If the address being minted to is not a contract, it works the same way as _mint
        _safeMint(msg.sender, tokenIds);
    }

    /**
     * @dev mint allows a user to mint 1 NFT per transaction after the presale has ended.
     * don't require whitelist check since this is a public mint
     */
    function mint() public payable onlyWhenNotPaused {
        // check that presale has ended
        require(
            presaleStarted && block.timestamp >= presaleEnded,
            "Presale has not ended yet"
        );
        require(tokenIds < maxTokenIds, "Exceed maximum Rookie Bots supply");
        require(msg.value >= _publicPrice, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    /**
     * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
     * returns an empty string for the baseURI
     * requires override keyword
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev setPaused makes the contract paused or unpaused
     */
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    /**
     * @dev withdraw all the ether in the contract
     * sent to the owner of the contract (the person who deployed the contract)
     */
    function withdraw() public onlyOwner {
        address _owner = owner(); // returns owner of this contract
        uint256 amount = address(this).balance; // balance of ether in this contract
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
