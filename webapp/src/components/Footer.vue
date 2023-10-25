<template>
    <div class="footer-wrap">
        <div class="footer-content">
            <div class="footer-links">
                <a href="https://www.bitcoin.com" target="_blank" rel="noreferrer"><img src="../assets/icons/brand.png" alt="Bitcoin.com" class="footer-brand-link"></a>
                <div class="short-links">
                    <a href="https://www.bitcoin.com/legal/user-agreement/" target="_blank" rel="noreferrer" class="short-link">User Agreement</a>
                    <a href="https://www.bitcoin.com/legal/cookies/" target="_blank" rel="noreferrer" class="short-link">Cookie Policy</a>
                    <a href="https://support.bitcoin.com/en/collections/3413550-verse-dex" target="_blank" rel="noreferrer" class="short-link">Need Help?</a>
                </div>
            </div>
            <div class="company">© 2023 Saint Bitts LLC Bitcoin.com. All rights reserved.</div>
        </div>
    </div>
</template>


<style lang="scss" scoped>
.footer-wrap {
    position: fixed;
    bottom: 0;
    left: 0;
    display: flex;
    justify-content: flex-end;
    box-sizing: border-box;
    width: 100%;
    padding: 1.5rem;
    flex-direction: column;
    flex: 0 1 0%;
    z-index: 1;
    color: rgb(255, 255, 255);
    background: rgb(0, 0, 0);
    .footer-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 1rem;
        .footer-links {
            display: flex;
            flex-wrap: wrap-reverse;
            align-items: center;
            gap: 1rem;
            .footer-brand-link {
                height: auto;
                object-fit: contain;
                width: 7.5rem;
            }
            .short-links {
                display: flex;
                flex-wrap: wrap;
                align-items: center;
                gap: 1rem;
                .short-link {
                    text-decoration: none;
                    font-size: 0.75rem;
                    font-weight: 400;
                    color: rgb(197, 206, 219);
                }
            }
        }
        .company {
            font-size: 0.75rem;
            font-weight: 400;
            color: rgb(88, 111, 145);
        }
    }

}
</style>