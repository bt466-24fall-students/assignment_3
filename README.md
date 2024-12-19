## **Requirements**

-   **Identify a publicly available dataset of your interest**

    -   ...such as from what featured in this article [10 Great Places To Find Open, Free Datasets \[2024 GuideLinks to an external site.\]Links to an external site.](https://careerfoundry.com/en/blog/data-analytics/where-to-find-free-datasets/)

    -   It shall be tabular data with columns and rows

        -   Columns shall be named

    -   It shall be in CSV format and under 50mb

    -   It shall relate to business 

        -   You and your groupmates must be able to make sense of it easily

-   **Clone the assignment repository, create RStudio Project**

    -   Create a branch with the name of your group

    -   Create a folder below the root with the name of your group

    -   Format Example: If you are Group 1, your branch and folder name should both be \`group_01\`.

    -   On your group branch, create an RStudio Project *within* your group folder

        -   The RStudio Project name should also be \`group_01\`

-   **Create an \`renv\` environment**

    -   It must contain a \`renv.lock\` file that records all packages used.  

    -   Please take note that renv will not record installed but not used packages. 

        -   You must make sure your \`renv.lock\` file reflects the packages you use after you have written all scripts 

-   **Write a script to download and read the dataset you've identified**

    -   This script should be called \`script.R\` 

    -   Download to \`raw_data\` folder inside your group folder

        -   This folder and all of its contents *should not be tracked* by Git

-   **Read the data you've downloaded into R environment**

    -   Use \`readr::read_csv()\` function

    -   Make sure to use relative path while referring to the data

    -   The data must be read as a data frame

    -   Assign the data frame to an informative and succinct name

    -   After running the script, the data frame should be the only object in the global environment 

-   **Ensure your script runs**

    -   Try testing your project on another group member's computer

    -   You must be able to run \`renv::restore()\` then source \`script.R\` without error  

    -   Check that the data exists in R and is as expected

-   **Push your progress to your group branch**

    -    and create a pull request on GitHub to the \`main\` branch 

-   **Discretional Extra Credit Opportunities (up to 20%):**

    -   You make "bite-sized" git commits after making changes to your repository

        -   ... in contrast to a big commit containing everything 

        -   The commits come with sensible messages that succinctly reflects the changes  

    -   Your code comes with sensible comments

### **Pass-Fail Criterion**


 -   Your code satisfies all of the above requirements (except for extra credit) and runs on my computer without error
