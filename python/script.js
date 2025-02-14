// 在 script.js 中添加您要使用的 JavaScript 碎片

document.addEventListener('DOMContentLoaded', function() {
    const searchBox = document.querySelector('.search-box');
    
    searchBox.addEventListener('input', function() {
        const searchTerm = this.value;
        console.log(`您輸入的內容：${searchTerm}`);
        
        // 搜索並顯示結果可以根據需求在這裡實現
        
    });
});
