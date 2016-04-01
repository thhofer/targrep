# targrep
Grepping within recursive tarballs

## Goal
This utility function searches for a given pattern within recursive tarballs
Within a single tarball, this can be achieved using `zgrep -a pattern archive.tar`, for instance.
However, when a tarball may contain other tarballs, it can be more tricky to obtain

## Sample use case

### Input
* parent.tar                                                                        
  * child1.tar                                                                      
    * subchild1-1.tar                                                               
      * path/to/file1.text                                                          
      * ...                                                                         
    * subchild1-2.tar                                                               
     * ...                                                                         
  * child2.tar                                                                      
    * subchild2-1.tar                                                               
      * path/to/otherfile.text                                                      
      * ...                                                                         
  * folder/otherfile.log
       
### Usage
If searching for the string "ERROR" within any file contained in any of the tarballs, you would:

1. Import the function: `source targrep.sh`
2. Call the function: `targrep "ERROR" parent.tar`

                                                         