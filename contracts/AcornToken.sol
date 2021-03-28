pragma solidity 0.7.6;

import "./libs/BEP20.sol";

contract AcornToken is BEP20("Acorn Token", "Acorn") {
    // start block
    uint256 public startBlock;
    // end block
    uint256 public endBlock;
    // fee address
    address public feeAddress;
    // investing address
    address public investAddress;
    // dev address
    address public devAddress;

    using SafeMath for uint256;

    uint256 private _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor(
        uint256 cap_,
        uint256 _startBlock,
        uint256 _endBlock,
        address dev,
        address fee,
        address invest
    ) {
        require(cap_ > 0, "BEP20Capped: cap is 0");
        _cap = cap_;
        startBlock = _startBlock;
        endBlock = _endBlock;
        devAddress = dev;
        feeAddress = fee;
        investAddress = invest;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {BEP20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - minted tokens must not cause the total supply to go over the cap.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // When minting tokens
            require(
                totalSupply().add(amount) <= _cap,
                "BEP20Capped: cap exceeded"
            );
            require(
                totalSupply().add(amount) <=
                    (_cap * (block.number - startBlock)) /
                        (endBlock - startBlock),
                "cannot mint so much at current time"
            );
        }
    }

    event SetFeeAddress(address indexed user, address indexed newAddress);
    event SetDevAddress(address indexed user, address indexed newAddress);
    event SetInvestAddress(address indexed user, address indexed newAddress);

    function mintable() external view returns (uint256) {
        return
            (_cap * (block.number - startBlock)) /
            (endBlock - startBlock) -
            totalSupply();
    }

    function setFeeAddress(address _feeAddress) public {
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        feeAddress = _feeAddress;
        emit SetFeeAddress(msg.sender, _feeAddress);
    }

    function setInvestAddress(address _investAddress) public {
        require(msg.sender == investAddress, "setinvestAddress: FORBIDDEN");
        investAddress = _investAddress;
        emit SetInvestAddress(msg.sender, _investAddress);
    }

    function setDevAddress(address _devAddress) public {
        require(msg.sender == devAddress, "setdevAddress: FORBIDDEN");
        devAddress = _devAddress;
        emit SetDevAddress(msg.sender, _devAddress);
    }

    function mint(uint256 _amount) public onlyOwner {
        // 25% to dev address
        _mint(devAddress, _amount.div(4));
        // 1215/4000 to fee address
        _mint(feeAddress, _amount.div(4000).mul(1215));
        // 1785/4000 to invest address
        _mint(investAddress, _amount.div(4000).mul(1785));
    }
}
