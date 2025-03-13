// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;



import "./SSTORE2.sol";



error YooooThatTokenIdIsWayTooHigh();

error GottaUnlockGen1Please();

error YoureNotTheOwnerHomie();



/*



     ██████   ██████   ██████  ██████  ██████  ██       ██████   ██████ ██   ██ ███████ 

    ██       ██    ██ ██    ██ ██   ██ ██   ██ ██      ██    ██ ██      ██  ██  ██      

    ██   ███ ██    ██ ██    ██ ██   ██ ██████  ██      ██    ██ ██      █████   ███████ 

    ██    ██ ██    ██ ██    ██ ██   ██ ██   ██ ██      ██    ██ ██      ██  ██       ██ 

     ██████   ██████   ██████  ██████  ██████  ███████  ██████   ██████ ██   ██ ███████ 

                                                                                        

                                                                                        

     ██████  ███████ ███    ██        ██                                                

    ██       ██      ████   ██       ███                                                

    ██   ███ █████   ██ ██  ██ █████  ██                                                

    ██    ██ ██      ██  ██ ██        ██                                                

     ██████  ███████ ██   ████        ██



    

    circles and squares

    🟡🟥



*/





contract goodblocksGen1

{

    // gen-1 description

    string private constant Gen1Description = unicode"who said circles and squares cant get along? welcome to gen-1 where these two shapes come together in perfect harmony. you know the drill... enjoy the art, explore the code, and dont forget to click around for some extra fun! 😉";







    /*



        ███████ ████████  ██████  ██████  ███████        

        ██         ██    ██    ██ ██   ██ ██             

        ███████    ██    ██    ██ ██████  █████          

             ██    ██    ██    ██ ██   ██ ██             

        ███████    ██     ██████  ██   ██ ███████        

                                                        

                                                        

        ██████   █████                                   

        ██   ██ ██   ██                                  

        ██   ██ ███████                                  

        ██   ██ ██   ██                                  

        ██████  ██   ██                 

               

                                                        

        ██████  ██       ██████   ██████ ██   ██ ███████ 

        ██   ██ ██      ██    ██ ██      ██  ██  ██      

        ██████  ██      ██    ██ ██      █████   ███████ 

        ██   ██ ██      ██    ██ ██      ██  ██       ██ 

        ██████  ███████  ██████   ██████ ██   ██ ███████



    */



    // gen-1 block struct

    struct Gen1Block

    {

        uint256 numLevels;

        uint256 widthInterval;

        uint256 circleCount;

        uint256 squareCount;

        uint256 noneCount;

        uint256 complexityLevel;

        bool glitchy;

        string svg;

        string name;

        string[4] palette;

    }



    // struct to store complex shapes

    struct ComplexShape

    {

        // array of addresses that store complex shape string pieces

        address[] pointers;

    }



    // 32 complex shapes for gen-1

    ComplexShape[32] private ComplexShapes;



    function readAddy(address _pointer) public view returns(string memory)

    {

        return string(SSTORE2.read(_pointer));

    }



    // add pointer to complex shape address data

    function addComplexShapePointer(uint256 _shapeIndex, uint256 _pointerIndex, address _pointer) external onlyOwner

    {

        // check if index is greater than length

        if(_pointerIndex >= ComplexShapes[_shapeIndex].pointers.length)

        {

            // push pointer

            ComplexShapes[_shapeIndex].pointers.push(_pointer);

        } else

        {

            // update pointer by index

            ComplexShapes[_shapeIndex].pointers[_pointerIndex] = _pointer;

        }

    }



    // add another sstore2 contract address to a complex shape array by index

    function addComplexShapeString(uint256 _shapeIndex, string memory _string) external onlyOwner

    {

        // write string and get pointer

        address _newPointer = SSTORE2.write(bytes(_string));

        // add pointer to complex shape array

        ComplexShapes[_shapeIndex].pointers.push(_newPointer);

    }



    // returns the svg shapes of a complex shape

    function getComplexShape(uint256 _shapeIndex) public view returns(string memory)

    {

        // if complex shape not loaded, return empty string

        if(ComplexShapes[_shapeIndex].pointers.length == 0)

        {

            return "";

        }



        uint256 i;

        string memory output;

        address[] memory pointers = ComplexShapes[_shapeIndex].pointers;

        unchecked

        {

            do

            {

                output = string.concat(output, string(SSTORE2.read(pointers[i])));

                ++i;

            } while(i<pointers.length);

        }

        return output;

    }



    // reset complex shape to rewrite shape

    function resetComplexShapePointers(uint256 _shapeIndex) external onlyOwner

    {

        delete ComplexShapes[_shapeIndex].pointers;

    }



    // borrowed colors and palettes from gen0

    string[7] private ColorGroupNames = ["Joy", "Night", "Cosmos", "Earth", "Arctic", "Serenity", "Twilight"];

    string[4][56] private ColorPalettes = 

    [

        ["#FDFF8F","#A8ECE7","#F4BEEE","#D47AE8"], // 0 palette (Joy)

        ["#FD6F96","#FFEBA1","#95DAC1","#6F69AC"],

        ["#FFDF6B","#FF79CD","#AA2EE6","#23049D"],

        ["#95E1D3","#EAFFD0","#FCE38A","#FF75A0"],

        ["#FFCC29","#F58634","#007965","#00AF91"],

        ["#998CEB","#77E4D4","#B4FE98","#FBF46D"],

        ["#EEEEEE","#77D970","#172774","#FF0075"],

        ["#005F99","#FF449F","#FFF5B7","#00EAD3"],

        ["#0B0B0D","#474A56","#929AAB","#D3D5FD"], // 1 palette (Night)

        ["#07031A","#4F8A8B","#B1B493","#FFCB74"],

        ["#2E3A63","#665C84","#71A0A5","#FAB95B"],

        ["#000000","#226089","#4592AF","#E3C4A8"],

        ["#1B1F3A","#53354A","#A64942","#FF7844"],

        ["#1a1a1a","#153B44","#2D6E7E","#C6DE41"],

        ["#0F0A3C","#07456F","#009F9D","#CDFFEB"],

        ["#130026","#801336","#C72C41","#EE4540"],

        ["#111D5E","#C70039","#F37121","#C0E218"], // 2 palette (Cosmos)

        ["#02383C","#230338","#ED5107","#C70D3A"],

        ["#03C4A1","#C62A88","#590995","#150485"],

        ["#00A8CC","#005082","#000839","#FFA41B"],

        ["#E94560","#0F3460","#16213E","#1A1A2E"],

        ["#D2FAFB","#FE346E","#512B58","#2C003E"],

        ["#706C61","#E1F4F3","#FFFFFF","#333333"],

        ["#FAF7F2","#2BB3C0","#161C2E","#EF6C35"],

        ["#FFFBE9","#E3CAA5","#CEAB93","#AD8B73"], // 3 palette (Earth)

        ["#A09F57","#C56824","#CFB784","#EADEB8"],

        ["#E3D0B9","#E1BC91","#C19277","#62959C"],

        ["#E9C891","#8A8635","#AE431E","#D06224"],

        ["#83B582","#D6E4AA","#FFFFC5","#F0DD92"],

        ["#303E27","#B4BB72","#E7EAA8","#F6FAF7"],

        ["#A8896C","#F1E8A7","#AED09E","#61B292"],

        ["#F4DFBA","#EEC373","#CA965C","#876445"],

        ["#42C2FF","#85F4FF","#B8FFF9","#EFFFFD"], // 4 palette (Arctic)

        ["#E8F0F2","#A2DBFA","#39A2DB","#053742"],

        ["#3E64FF","#5EDFFF","#B2FCFF","#ECFCFF"],

        ["#D1FFFA","#4AA9AF","#3E31AE","#1C226B"],

        ["#F7F3F3","#C1EAF2","#5CC2F2","#191BA9"],

        ["#F3F3F3","#303841","#3A4750","#2185D5"],

        ["#769FCD","#B9D7EA","#D6E6F2","#F7FBFC"],

        ["#3D6CB9","#00D1FF","#00FFF0","#FAFAF6"],

        ["#99FEFF","#94DAFF","#94B3FD","#B983FF"], // 5 palette (Serenity)

        ["#E5707E","#E6B566","#E8E9A1","#A3DDCB"],

        ["#6892D5","#79D1C3","#C9FDD7","#F8FCFB"],

        ["#6C5B7B","#C06C84","#F67280","#F8B195"],

        ["#30475E","#BA6B57","#F1935C","#E7B2A5"],

        ["#FFEBD3","#264E70","#679186","#FFB4AC"],

        ["#6DDCCF","#94EBCD","#FFEFA1","#FFCB91"],

        ["#D8EFF0","#B0E0A8","#F0F69F","#F3C1C6"],

        ["#35477D","#6C5B7B","#C06C84","#F67280"], // 6 palette (Twilight)

        ["#F6C065","#55B3B1","#AF0069","#09015F"],

        ["#470D21","#9C0F48","#D67D3E","#F9E4D4"],

        ["#001F52","#A10054","#FF8D68","#FFECBA"],

        ["#FF6C00","#A0204C","#23103A","#282D4F"],

        ["#FFF9B2","#ECAC5D","#B24080","#3F0713"],

        ["#FFE98A","#C84771","#61105E","#280B45"],

        ["#EDE862","#FA9856","#F27370","#22559C"]

    ];



    // bones of the gen-1 svg

    address[4] private SVGAddresses;



    // set svg piece

    function setSvgPiece(uint256 _index, string memory _string) external onlyOwner returns(address)

    {

        SVGAddresses[_index] = SSTORE2.write(bytes(_string));

        return SVGAddresses[_index];

    }

    

    // read svg piece

    function readSvgPiece(uint256 _index) public view returns(string memory)

    {

        return string(SSTORE2.read(SVGAddresses[_index]));

    }

    





    /*



        ███    ███  █████  ██   ██ ███████               

        ████  ████ ██   ██ ██  ██  ██                    

        ██ ████ ██ ███████ █████   █████                 

        ██  ██  ██ ██   ██ ██  ██  ██                    

        ██      ██ ██   ██ ██   ██ ███████               

                                                        

                                                        

        ██████   █████                                   

        ██   ██ ██   ██                                  

        ██   ██ ███████                                  

        ██   ██ ██   ██                                  

        ██████  ██   ██                 

                                                        

                                                        

        ██████  ██       ██████   ██████ ██   ██ ███████ 

        ██   ██ ██      ██    ██ ██      ██  ██  ██      

        ██████  ██      ██    ██ ██      █████   ███████ 

        ██   ██ ██      ██    ██ ██      ██  ██       ██ 

        ██████  ███████  ██████   ██████ ██   ██ ███████



    */



    // get token uri for gen-1

    function tokenGenURI(uint256 _tokenId, string memory _tokenMetadata, string memory _tokenAttributes) public view returns(string memory)

    {

        // check if valid token ID

        if(_tokenId > 8280) revert YooooThatTokenIdIsWayTooHigh();

        // get token data

        IGBContract.TokenData memory tokenData = GBTokenContract.getTokenData(_tokenId);

        // check if gen-1 has been unlocked

        if(tokenData.highestGenLevel < 1) revert GottaUnlockGen1Please();

        // get gen-0 block

        IGen0Contract.GoodBlock memory gen0_block = Gen0Contract.tokenToGoodblock(_tokenId);

        // get gen-1 block

        Gen1Block memory gen1_block = getGen1Block(_tokenId, tokenData, gen0_block);

        // get token metadata

        string memory metadata = blockToMetadata(tokenData, gen0_block, gen1_block, _tokenAttributes);



        // construct token uri

        string memory tokenUri = string.concat(

            '{"name":"',

            ColorGroupNames[gen0_block.colorGroupIndex],

            ' #',

            OZ.toString(_tokenId),

            '","description":"',

            Gen1Description,

            '",',

            _tokenMetadata,

            ',"attributes":[',

            metadata,

            '],"image":"data:image/svg+xml;base64,',

            string(OZ.encode(bytes(gen1_block.svg))),

            '"}'

        );

        // return that suckah!

        return string.concat("data:application/json;base64,", string(OZ.encode(bytes(tokenUri))));

    }



    // get token svg (interoperability)

    function getTokenSVG(uint256 _tokenId) public view returns(string memory)

    {

        // check if valid token ID

        if(_tokenId > 8280) revert YooooThatTokenIdIsWayTooHigh();

        // get token data

        IGBContract.TokenData memory tokenData = GBTokenContract.getTokenData(_tokenId);

        // check if gen-1 has been unlocked

        if(tokenData.highestGenLevel < 1) revert GottaUnlockGen1Please();

        // get gen-0 block

        IGen0Contract.GoodBlock memory gen0_block = Gen0Contract.tokenToGoodblock(_tokenId);



        Gen1Block memory gen1Block = getGen1Block(_tokenId, tokenData, gen0_block);

        return gen1Block.svg;

    }



    // get gen-1 block

    function getGen1Block(uint256 _tokenId, IGBContract.TokenData memory _tokenData, IGen0Contract.GoodBlock memory _gen0block) private view returns(Gen1Block memory)

    {

        // create gen-1 block

        Gen1Block memory gen1_block;

        // create token id as string

        string memory tokenIdString = OZ.toString(_tokenId);

        unchecked

        {

            // set levels and shape width interval

            gen1_block.numLevels = (random(string.concat(tokenIdString, "create x innovate x impact x do good"))%4) + 5;

            gen1_block.widthInterval = 3000/gen1_block.numLevels;   

            // retrieve color palette

            string[4] memory palette = ColorPalettes[(_gen0block.colorGroupIndex * 8) + _gen0block.paletteIndex];    

            gen1_block.palette = palette;

        }

        // get svg

        gen1_block.svg = getGen1SVG(_tokenId, _tokenData, _gen0block, gen1_block);

        // return gen-1 block

        return gen1_block;

    }

    

    // generate svg for gen-1 block

    function getGen1SVG(uint256 _tokenId, IGBContract.TokenData memory _tokenData, IGen0Contract.GoodBlock memory _gen0Block,  Gen1Block memory _gen1Block) private view returns(string memory)

    {

        uint256 width;

        uint256 shapeDesign;

        uint256 tokenRand;

        uint256 scale;

        uint256 i;



        // svg intro

        string memory svg = string.concat(

            readSvgPiece(1),

            '<g id="art"',

            _gen0Block.symmetryIndex == 5 ? ' filter="url(#glitch)">\n\n' : '>\n\n',

            '<rect x="0" y="0" width="100%" height="100%" fill="',

            _gen0Block.isDarkBlock ? '#000' : _gen1Block.palette[0],

            '"/>\n\n<g id="shapes"',

            _gen0Block.symmetryIndex == 5 ? ' filter="url(#noise)">\n\n' : '>\n\n'

        );



        unchecked

        {

            do

            {

                // get random number

                tokenRand = (_tokenId+13)*(i+1);

                

                // check if complexity is possible

                if(_gen1Block.complexityLevel > 1  || i > 5)

                {

                    // get simpler shape

                    shapeDesign = getShapeDesign(tokenRand, 150);

                } else

                {

                    // get more complex shape

                    shapeDesign = getShapeDesign(tokenRand, 300);

                }



                // update width

                width = _gen1Block.widthInterval*(_gen1Block.numLevels-i);



                // none

                if(shapeDesign == 0)

                {

                    // nothing to see here folks!

                    ++_gen1Block.noneCount;





                // basic circle

                } else if(shapeDesign == 1)

                {

                    // add to svg

                    svg = string.concat(

                        svg,

                        '<g id="shapeGroup_',

                        OZ.toString(i),

                        '" fill="',

                        _gen0Block.isDarkBlock && (tokenRand % 13 == 0) ? "#000" : _gen1Block.palette[(tokenRand+1)%4],

                        '" stroke="',

                        _gen1Block.palette[(tokenRand+2)%4],

                        '" stroke-width="50">\n',

                        drawCircle(width/2),

                        '</g>\n\n'

                    );

                    ++_gen1Block.circleCount;





                // basic square

                } else if(shapeDesign == 2)

                {

                    // add to svg

                    svg = string.concat(

                        svg,

                        '<g id="shapeGroup_',

                        OZ.toString(i),

                        '" fill="',

                        _gen0Block.isDarkBlock && (tokenRand % 13 == 0) ? "#000" : _gen1Block.palette[(tokenRand+10)%4],

                        '" stroke="',

                        _gen1Block.palette[(tokenRand+11)%4],

                        '" stroke-width="50">\n',

                        drawSquare(width),

                        '</g>\n\n'

                    );

                    ++_gen1Block.squareCount;





                // repeated circle

                } else if(shapeDesign == 3)

                {

                    // add to svg

                    scale = (width*100)/(4000);

                    svg = string.concat(

                        svg,

                        '<g id="shapeGroup_',

                        OZ.toString(i),

                        string.concat(

                            '" fill="',

                            _gen0Block.isDarkBlock && (tokenRand % 13 == 0) ? "#000" : _gen1Block.palette[(tokenRand+3)%4],

                            '" stroke="',

                            _gen1Block.palette[(tokenRand+4)%4]

                            ),

                        '" stroke-width="10" transform="translate(',

                        string.concat(addDecimalFromTheRight(200000-2000*(scale), 2), ', ', addDecimalFromTheRight(200000-2000*(scale), 2))

                    );

                    svg = string.concat(

                        svg,

                        ') scale(',

                        string.concat(addDecimalFromTheRight((scale), 2), ', ', addDecimalFromTheRight((scale), 2)),

                        ')" >\n',

                        getComplexShape((tokenRand)%12),

                        '</g>\n\n'

                    );

                    // update counts

                    ++_gen1Block.circleCount;

                    ++_gen1Block.complexityLevel;





                // repeated square

                } else if(shapeDesign == 4)

                {

                    // add to svg

                    scale = (width*100)/(4000);

                    svg = string.concat(

                        svg,

                        '<g id="shapeGroup_',

                        OZ.toString(i),

                        string.concat(

                            '" fill="',

                            _gen0Block.isDarkBlock && (tokenRand % 13 == 0) ? "#000" : _gen1Block.palette[(tokenRand+3)%4],

                            '" stroke="',

                            _gen1Block.palette[(tokenRand+4)%4]

                            ),

                        '" stroke-width="10" transform="translate(',

                        string.concat(addDecimalFromTheRight(200000-2000*(scale), 2), ', ', addDecimalFromTheRight(200000-2000*(scale), 2))

                    );

                    svg = string.concat(

                        svg,

                        ') scale(',

                        string.concat(addDecimalFromTheRight((scale), 2), ', ', addDecimalFromTheRight((scale), 2)),

                        ')" >\n',

                        getComplexShape((tokenRand)%12),

                        '</g>\n\n'

                    );

                    // update counts

                    ++_gen1Block.squareCount;

                    ++_gen1Block.complexityLevel;





                // rotated square same

                } else if(shapeDesign == 5)

                {

                    // add to svg

                    scale = (width*100)/(4000);

                    svg = string.concat(

                        svg,

                        '<g id="shapeGroup_',

                        OZ.toString(i),

                        string.concat(

                            '" fill="',

                            _gen0Block.isDarkBlock && (tokenRand % 13 == 0) ? "#000" : _gen1Block.palette[(tokenRand+3)%4],

                            '" stroke="',

                            _gen1Block.palette[(tokenRand+4)%4]

                            ),

                        '" stroke-width="10" transform="translate(',

                        string.concat(addDecimalFromTheRight(200000-2000*(scale), 2), ', ', addDecimalFromTheRight(200000-2000*(scale), 2))

                    );

                    svg = string.concat(

                        svg,

                        ') scale(',

                        string.concat(addDecimalFromTheRight((scale), 2), ', ', addDecimalFromTheRight((scale), 2)),

                        ')" >\n',

                        getComplexShape((tokenRand)%12),

                        '</g>\n\n'

                    );

                    // update counts

                    ++_gen1Block.squareCount;

                    ++_gen1Block.complexityLevel;





                //rotated square bi direction

                } else if(shapeDesign == 6)

                {

                    // add to svg

                    scale = (width*100)/(4000);

                    svg = string.concat(

                        svg,

                        '<g id="shapeGroup_',

                        OZ.toString(i),

                        string.concat(

                            '" fill="',

                            _gen0Block.isDarkBlock && (tokenRand % 13 == 0) ? "#000" : _gen1Block.palette[(tokenRand+7)%4],

                            '" stroke="',

                            _gen1Block.palette[(tokenRand+8)%4]

                            ),

                        '" stroke-width="10" transform="translate(',

                        string.concat(addDecimalFromTheRight(200000-2000*(scale), 2), ', ', addDecimalFromTheRight(200000-2000*(scale), 2))

                    );

                    svg = string.concat(

                        svg,

                        ') scale(',

                        string.concat(addDecimalFromTheRight((scale), 2), ', ', addDecimalFromTheRight((scale), 2)),

                        ')" >\n',

                        getComplexShape(((tokenRand)%12)+12),

                        '</g>\n\n'

                    );

                    // update counts

                    ++_gen1Block.squareCount;

                    ++_gen1Block.complexityLevel;

                }

                // iterate to next shape

                ++i;



            // continue until all levels are complete

            } while (i<_gen1Block.numLevels);

        }



        // return final svg

        return string.concat(

            readSvgPiece(0),

            getTokenDataString(_tokenId, _tokenData, _gen0Block, _gen1Block),

            svg,

            // end shapes group and add token name

            readSvgPiece(2),

            _gen0Block.symmetryIndex == 5 ? readSvgPiece(3) : '',

            '\n\n</svg>' // close svg

        );

    }



    // get metadata for gen-1 block

    function blockToMetadata(IGBContract.TokenData memory _tokenData, IGen0Contract.GoodBlock memory _gen0Block, Gen1Block memory _gen1Block, string memory _tokenAttributes) private view returns(string memory)

    {

        // get attribute substring

        string[2] memory ogAttributes = cleanAttributes(_tokenAttributes);

        // begin metadata

        string memory metadata = string.concat(

            '{"trait_type": "Generations Unlocked", "value":',

            OZ.toString(_tokenData.highestGenLevel+1),

            '},{"trait_type": "Active Generation", "value":',

            OZ.toString(_tokenData.activeGen),

            '},{"trait_type": "Times Transferred", "value":"',

            ogAttributes[0],

            '"},{"trait_type": "Owned Since", "value":"',

            ogAttributes[1]

        );

        metadata = string.concat(

            metadata,

            '"},{"trait_type": "Color Group", "value":"',

            ColorGroupNames[_gen0Block.colorGroupIndex],

            '"},{"trait_type": "Palette Index", "value":"',

            OZ.toString(_gen0Block.paletteIndex),



            '{"trait_type": "Shape Count", "value":"',

            OZ.toString(_gen1Block.numLevels),

            '"},{"trait_type": "Circle Count", "value":"',

            OZ.toString(_gen1Block.circleCount),

            '"},{"trait_type": "Square Count", "value":"',

            OZ.toString(_gen1Block.squareCount),

            '"},{"trait_type": "None Count", "value":"',

            OZ.toString(_gen1Block.noneCount)

        );

        metadata = string.concat(

            metadata,

            '"},{"trait_type": "Complexity Level", "value":"',

            OZ.toString(_gen1Block.complexityLevel),

            '"},{"trait_type": "Glitchy", "value":"',

            _gen0Block.symmetryIndex == 5 ? "True" : "False",

            '"},{"trait_type": "Special Trait", "value":"',

            _gen0Block.isDarkBlock ? 'Do Good"}' : 'None"}'

        );

        // return metadata string

        return metadata;

    }



    // create token data string

    function getTokenDataString(uint256 _tokenId, IGBContract.TokenData memory _tokenData, IGen0Contract.GoodBlock memory _gen0Block, Gen1Block memory _gen1Block) private view returns(string memory)

    {

        // create name

        _gen1Block.name = string.concat(ColorGroupNames[_gen0Block.colorGroupIndex], ' #', OZ.toString(_tokenId));

        // begin token data string for token

        string memory tokenDataString = string.concat(

            OZ.toString(_tokenId),

            "|",

            _gen1Block.name,

            "|",

            OZ.toHexString(_tokenData.tokenOwner),

            "|",

            OZ.toString(_tokenData.ownedSince),

            "|",

            OZ.toString(_tokenData.timesTransferred),

            "|",

            OZ.toString(_tokenData.highestGenLevel + 1),

            "|",

            OZ.toString(_tokenData.activeGen),

            "|",

            ColorGroupNames[_gen0Block.colorGroupIndex],

            "|",

            OZ.toString(_gen0Block.paletteIndex),

            "|"

        );

        tokenDataString = string.concat(

            tokenDataString,

            OZ.toString(_gen1Block.numLevels),

            "|",

            OZ.toString(_gen1Block.circleCount),

            "|",

            OZ.toString(_gen1Block.squareCount),

            "|",

            OZ.toString(_gen1Block.noneCount),

            "|",

            OZ.toString(_gen1Block.complexityLevel),

            "|",

            _gen0Block.symmetryIndex == 5 ? "true" : "false",

            "|",

            _gen0Block.isDarkBlock ? "Do Good" : "None",

            "|",

            _gen1Block.palette[0],

            "|",

            _gen1Block.palette[1],

            "|",

            _gen1Block.palette[2],

            "|",

            _gen1Block.palette[3]

        );

        // return token data string

        return tokenDataString;

    }



    // determine shape design

    function getShapeDesign(uint256 _seed, uint256 _limit) private pure returns(uint256)

    {

        // set shape weights

        uint8[7] memory ShapeDesignWeights = [50, 50, 50, 15, 15, 60, 60];

        // select a shape at random

        unchecked

        {

            uint256 index = 0;

            uint256 j = ShapeDesignWeights[0];

            uint256 i = random(string.concat("its a good day", OZ.toString(_seed*13), "to have a good day"))%_limit;

            while (j <= i)

            {

                ++index;

                j += ShapeDesignWeights[index];

            }

            return index;

        }

    }







    /*



        ██████  ██    ██ ██████  ██      ██  ██████           

        ██   ██ ██    ██ ██   ██ ██      ██ ██                

        ██████  ██    ██ ██████  ██      ██ ██                

        ██      ██    ██ ██   ██ ██      ██ ██                

        ██       ██████  ██████  ███████ ██  ██████           

                                                            

                                                            

        ████████  ██████   ██████  ██      ██ ███████ ███████ 

           ██    ██    ██ ██    ██ ██      ██ ██      ██      

           ██    ██    ██ ██    ██ ██      ██ █████   ███████ 

           ██    ██    ██ ██    ██ ██      ██ ██           ██ 

           ██     ██████   ██████  ███████ ██ ███████ ███████ 

                                                                                                       

    */



    // draw circle centered at (2000,2000)

    function drawCircle(uint256 _radius) public pure returns(string memory)

    {

        return string.concat(

            '<circle cx="2000" cy="2000" r="',

            OZ.toString(_radius),

            '"/>\n'

        );

    }



    // draw circle centered at (2000,2000)

    function drawSquare(uint256 _width) public pure returns(string memory)

    {

        uint256 o = 2000 - _width/2;

        string memory outputSVG = string.concat(

            '<rect x="',

            OZ.toString(o),

            '" y="',

            OZ.toString(o),

            '" width="',

            OZ.toString(_width),

            '" height="',

            OZ.toString(_width),

            '"/>\n'

        );

        return outputSVG;

    }



    // add decimal number from the right

    function addDecimalFromTheRight(uint256 _number, uint256 _sigFigs) public pure returns(string memory)

    {

        // get initial variables

        string memory numString = OZ.toString(_number);

        uint256 length = bytes(numString).length;

        bytes memory decimal = new bytes(_sigFigs);



        unchecked

        {

            // check if sig fig greater thant length (0 padded)

            if(_sigFigs > length)

            {

                uint256 i = _sigFigs-length;

                do

                {

                    if(i < _sigFigs-length)

                    {

                        decimal[i] = bytes("0")[0];

                    } else

                    {

                        decimal[i] = bytes(numString)[i-(_sigFigs-length)];

                    }

                    --i;

                } while(i>0);

                

                decimal[0] = "0";

                // return string

                return string.concat("0", ".", string(decimal));



            // sig figs is = length

            } else if(_sigFigs == length)

            {

                // return string

                return string.concat("0", ".", numString);

            

            // sig figs < length

            } else

            {

                uint256 wholeIndex;

                uint256 decimalIndex;

                uint256 i;

                bytes memory whole = new bytes(length-_sigFigs);

                do

                {

                    if(i < length-_sigFigs)

                    {

                        whole[wholeIndex] = bytes(numString)[i];

                        ++wholeIndex;

                    } else

                    {

                        decimal[decimalIndex] = bytes(numString)[i];

                        ++decimalIndex;

                    }

                    ++i;

                } while(i<length);

                

                // return string

                return string.concat(string(whole), ".", string(decimal));

            }   

        }

    }



    // get random number back

    function random(string memory _input) public pure returns (uint256)

    {

        return uint256(keccak256(abi.encodePacked(_input)));

    }



    // attribute data

    struct AttData

    {

        uint256 ownedStart;

        uint256 ownedEnd;

        uint256 ownedLength;

        uint256 transferStart;

        uint256 transferEnd;

        uint256 transferLength;

    }



    // funciton clean original attributes

    function cleanAttributes(string memory _attributes) public pure returns(string[2] memory)

    {

        uint256 i;

        bytes memory attBytes = bytes(_attributes);

        AttData memory attData;

        // get time owned attribute

        attData.ownedEnd = attBytes.length-3;

        for(i=attData.ownedEnd; i>0; --i)

        {

            if(attBytes[i] == bytes1('"'))

            {

                attData.ownedStart = i+1;

                attData.ownedLength = (attData.ownedEnd-attData.ownedStart+1);

                break;

            }

        }

        // get times transfrerred attribute

        attData.transferEnd = attData.ownedStart-43;

        for(i=attData.transferEnd; i>0; --i)

        {

            if(attBytes[i] == bytes1('"'))

            {

                attData.transferStart = i+1;

                attData.transferLength = (attData.transferEnd-attData.transferStart+1);

                break;

            }            

        }



        bytes memory timesTransferredBytes = new bytes(attData.transferLength);

        bytes memory ownedSinceBytes = new bytes(attData.ownedLength);

        

        for(i=0; i<attData.transferLength; i++)

        {

            timesTransferredBytes[i] = attBytes[attData.transferStart + i];

        }

        

        for(i=0; i<attData.ownedLength; i++)

        {

            ownedSinceBytes[i] = attBytes[attData.ownedStart + i];

        }



        // return attributes

        return [string(timesTransferredBytes), string(ownedSinceBytes)];

    }







    /*



        ██ ███    ██ ████████ ███████ ██████  ███████  █████   ██████ ███████

        ██ ████   ██    ██    ██      ██   ██ ██      ██   ██ ██      ██     

        ██ ██ ██  ██    ██    █████   ██████  █████   ███████ ██      █████  

        ██ ██  ██ ██    ██    ██      ██   ██ ██      ██   ██ ██      ██     

        ██ ██   ████    ██    ███████ ██   ██ ██      ██   ██  ██████ ███████



        ███████ ████████ ██    ██ ███████ ███████ 

        ██         ██    ██    ██ ██      ██      

        ███████    ██    ██    ██ █████   █████   

             ██    ██    ██    ██ ██      ██      

        ███████    ██     ██████  ██      ██



    */



    // interface contracts

    IGBContract private GBTokenContract = IGBContract(address(0x29B4Ea6B1164C7cd8A3a0a1dc4ad88d1E0589124));

    IGen0Contract private Gen0Contract = IGen0Contract(address(0xAd77f8106d1E4891be0428133f35F78977671F2F));

    

    // set contract addresses

    function setInterfaceAddresses(address[2] memory _newAddresses) external onlyOwner

    {

        GBTokenContract = IGBContract(_newAddresses[0]);

        Gen0Contract = IGen0Contract(_newAddresses[1]);    

    } 







    /*

  

         ██████  ██     ██ ███    ██ ███████ ██████      ███████ ██   ██ ██ ███████ 

        ██    ██ ██     ██ ████   ██ ██      ██   ██     ██      ██   ██ ██    ███  

        ██    ██ ██  █  ██ ██ ██  ██ █████   ██████      ███████ ███████ ██   ███   

        ██    ██ ██ ███ ██ ██  ██ ██ ██      ██   ██          ██ ██   ██ ██  ███    

         ██████   ███ ███  ██   ████ ███████ ██   ██     ███████ ██   ██ ██ ███████

  

    */



    // construct that thing

    constructor()

    {

        ContractOwner = msg.sender;

    }



    // contract owner 

    address private ContractOwner;



    // only owner modifier

    function _onlyOwner() private view

    {

        if(msg.sender != ContractOwner) revert YoureNotTheOwnerHomie();

    }

    modifier onlyOwner()

    {

        _onlyOwner();

        _;

    }



    // transfer contract ownership

    function transferOwnership(address _newOwner) external onlyOwner

    {

        ContractOwner = _newOwner;

    }



    // if youre reading this, make a goodblocks collage with all our tokens

}





// interface for the goodblocks contract

interface IGBContract

{

    struct TokenData

    {

        uint8 activeGen;

        uint8 highestGenLevel;

        uint64 timesTransferred;

        uint64 ownedSince;

        address tokenOwner;

    }

    function ownerOf(uint256 _tokenId) external view returns(address);

    function getTokenData(uint256 _tokenId) external view returns (TokenData memory);

}



// interface for the gen-0 contract

interface IGen0Contract

{

    struct GoodBlock

    {

        uint8 pixelSizeIndex;

        uint8 symmetryIndex;

        uint8 colorGroupIndex;

        uint8 paletteIndex;

        bool isDarkBlock; 

        uint16 tokenIndex;

        bytes3 labelColor;

        string blockDNA;

    }

    

    function tokenToGoodblock(uint256 _tokenId) external view returns(GoodBlock memory);

}







/*



        ██      ██ ██████  ██████   █████  ██████  ██ ███████ ███████ 

        ██      ██ ██   ██ ██   ██ ██   ██ ██   ██ ██ ██      ██      

        ██      ██ ██████  ██████  ███████ ██████  ██ █████   ███████ 

        ██      ██ ██   ██ ██   ██ ██   ██ ██   ██ ██ ██           ██ 

        ███████ ██ ██████  ██   ██ ██   ██ ██   ██ ██ ███████ ███████



        using OpenZeppelin Strings and Base64 contracts



    */



library OZ

{

    // OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    uint8 private constant _ADDRESS_LENGTH = 20;

    /**

     * @dev Return the log in base 10, rounded down, of a positive value.

     * Returns 0 if given 0.

     */

    function log10(uint256 value) internal pure returns (uint256)

    {

        uint256 result = 0;

        unchecked

        {

            if (value >= 10**64)

            {

                value /= 10**64;

                result += 64;

            }

            if (value >= 10**32)

            {

                value /= 10**32;

                result += 32;

            }

            if (value >= 10**16)

            {

                value /= 10**16;

                result += 16;

            }

            if (value >= 10**8)

            {

                value /= 10**8;

                result += 8;

            }

            if (value >= 10**4)

            {

                value /= 10**4;

                result += 4;

            }

            if (value >= 10**2)

            {

                value /= 10**2;

                result += 2;

            }

            if (value >= 10**1)

            {

                result += 1;

            }

        }

        return result;

    }

    /**

     * @dev Converts a `uint256` to its ASCII `string` decimal representation.

     */

    function toString(uint256 value) internal pure returns (string memory)

    {

        unchecked

        {

            uint256 length = log10(value) + 1;

            string memory buffer = new string(length);

            uint256 ptr;

            /// @solidity memory-safe-assembly

            assembly

            {

                ptr := add(buffer, add(32, length))

            }

            while (true)

            {

                ptr--;

                /// @solidity memory-safe-assembly

                assembly

                {

                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))

                }

                value /= 10;

                if (value == 0) break;

            }

            return buffer;

        }

    }

    /**

     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.

     */

    function toHexString(address addr) internal pure returns (string memory)

    {

        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);

    }

    /**

     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.

     */

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory)

    {

        bytes memory buffer = new bytes(2 * length + 2);

        buffer[0] = "0";

        buffer[1] = "x";

        for (uint256 i = 2 * length + 1; i > 1; --i)

        {

            buffer[i] = _SYMBOLS[value & 0xf];

            value >>= 4;

        }

        require(value == 0, "Strings: hex length insufficient");

        return string(buffer);

    }





    // OpenZeppelin Contracts (last updated v4.7.0) (utils/Base64.sol)

    /**

     * @dev Base64 Encoding/Decoding Table

     */

    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**

     * @dev Converts a `bytes` to its Bytes64 `string` representation.

     */

    function encode(bytes memory data) internal pure returns (string memory)

    {

        /**

         * Inspired by Brecht Devos (Brechtpd) implementation - MIT licence

         * https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol

         */

        if (data.length == 0) return "";



        // Loads the table into memory

        string memory table = _TABLE;



        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter

        // and split into 4 numbers of 6 bits.

        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up

        // - `data.length + 2`  -> Round up

        // - `/ 3`              -> Number of 3-bytes chunks

        // - `4 *`              -> 4 characters for each chunk

        string memory result = new string(4 * ((data.length + 2) / 3));



        /// @solidity memory-safe-assembly

        assembly

        {

            // Prepare the lookup table (skip the first "length" byte)

            let tablePtr := add(table, 1)



            // Prepare result pointer, jump over length

            let resultPtr := add(result, 32)



            // Run over the input, 3 bytes at a time

            for

            {

                let dataPtr := data

                let endPtr := add(data, mload(data))

            } lt(dataPtr, endPtr)

            {



            }

            {

                // Advance 3 bytes

                dataPtr := add(dataPtr, 3)

                let input := mload(dataPtr)



                // To write each character, shift the 3 bytes (18 bits) chunk

                // 4 times in blocks of 6 bits for each character (18, 12, 6, 0)

                // and apply logical AND with 0x3F which is the number of

                // the previous character in the ASCII table prior to the Base64 Table

                // The result is then added to the table to get the character to write,

                // and finally write it in the result pointer but with a left shift

                // of 256 (1 byte) - 8 (1 ASCII char) = 248 bits



                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))

                resultPtr := add(resultPtr, 1) // Advance



                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))

                resultPtr := add(resultPtr, 1) // Advance



                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))

                resultPtr := add(resultPtr, 1) // Advance



                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))

                resultPtr := add(resultPtr, 1) // Advance

            }



            // When data `bytes` is not exactly 3 bytes long

            // it is padded with `=` characters at the end

            switch mod(mload(data), 3)

            case 1

            {

                mstore8(sub(resultPtr, 1), 0x3d)

                mstore8(sub(resultPtr, 2), 0x3d)

            }

            case 2

            {

                mstore8(sub(resultPtr, 1), 0x3d)

            }

        }

        return result;

    }

}