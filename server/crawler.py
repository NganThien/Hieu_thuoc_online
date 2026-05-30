import requests
from bs4 import BeautifulSoup
import json
import re
from urllib.parse import urljoin

# Configuration
BASE_URL = "https://nhathuoclongchau.com.vn"
OUTPUT_FILE = "mock_medicines.json"
MAX_PRODUCTS = 50

# Categories to scrape (2-3 common categories)
CATEGORIES = [
    {
        "name": "Vitamins",
        "url": "https://nhathuoclongchau.com.vn/thuc-pham-chuc-nang/vitamin-khoang-chat"
    },
    {
        "name": "Pain Relief",
        "url": "https://nhathuoclongchau.com.vn/thuoc/giam-dau"
    },
    {
        "name": "Medical Supplies",
        "url": "https://nhathuoclongchau.com.vn/trang-thiet-bi-y-te"
    }
]

# Headers to avoid blocking
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
    "Accept-Encoding": "gzip, deflate",
    "Connection": "keep-alive",
}

def parse_price(price_str):
    """
    Parse price string to integer.
    Removes dots, commas, and currency symbols (đ, VND).
    Example: "15.000đ" -> 15000
    """
    if not price_str:
        return 0
    
    # Remove dots, commas, and currency symbols
    cleaned = re.sub(r'[.,đVND\s]', '', str(price_str))
    
    try:
        return int(cleaned)
    except ValueError:
        return 0

def get_product_links(category_url, max_products_per_category):
    """
    Get product links from a category page.
    """
    try:
        response = requests.get(category_url, headers=HEADERS, timeout=10)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        
        product_links = []
        
        # Try multiple selectors for product links
        selectors = [
            'a.product-item-link',
            'a[href*="/thuc-pham-chuc-nang/"]',
            'a[href*="/thuoc/"]',
            'a[href*="/trang-thiet-bi-y-te/"]',
            '.product-name a',
            '.item-product a',
        ]
        
        for selector in selectors:
            links = soup.select(selector)
            if links:
                for link in links[:max_products_per_category]:
                    href = link.get('href')
                    if href and href.startswith('/'):
                        full_url = urljoin(BASE_URL, href)
                        if full_url not in product_links:
                            product_links.append(full_url)
                if product_links:
                    break
        
        return product_links[:max_products_per_category]
    
    except Exception as e:
        print(f"Error getting product links from {category_url}: {e}")
        return []

def scrape_product(product_url, category_name):
    """
    Scrape product details from a product page.
    """
    try:
        response = requests.get(product_url, headers=HEADERS, timeout=10)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Extract product name
        name = ""
        name_selectors = [
            'h1.product-name',
            'h1',
            '.product-title',
            '#product-name',
        ]
        for selector in name_selectors:
            element = soup.select_one(selector)
            if element:
                name = element.get_text(strip=True)
                break
        
        # Extract price
        price = 0
        price_selectors = [
            '.price-box .price',
            '.product-price',
            '.price',
            '[itemprop="price"]',
            '.special-price',
        ]
        for selector in price_selectors:
            element = soup.select_one(selector)
            if element:
                price_text = element.get_text(strip=True)
                price = parse_price(price_text)
                if price > 0:
                    break
        
        # Extract description
        description = ""
        desc_selectors = [
            '.product-description',
            '.description',
            '#product-description',
            '.product-info',
            '.short-description',
        ]
        for selector in desc_selectors:
            element = soup.select_one(selector)
            if element:
                description = element.get_text(strip=True)[:500]  # Limit description length
                break
        
        # If no description found, try to get from meta description
        if not description:
            meta_desc = soup.find('meta', attrs={'name': 'description'})
            if meta_desc:
                description = meta_desc.get('content', '')[:500]
        
        # Extract image URL
        image_url = ""
        img_selectors = [
            '.product-img-box img',
            '.product-image img',
            '.fancybox img',
            '#product-img img',
            '.main-image img',
        ]
        for selector in img_selectors:
            element = soup.select_one(selector)
            if element:
                image_url = element.get('src') or element.get('data-src')
                if image_url:
                    if image_url.startswith('//'):
                        image_url = 'https:' + image_url
                    elif image_url.startswith('/'):
                        image_url = urljoin(BASE_URL, image_url)
                    break
        
        # Generate ID from URL
        product_id = product_url.split('/')[-1].replace('.html', '')
        
        return {
            "id": product_id,
            "name": name,
            "price": price,
            "description": description,
            "category": category_name,
            "imageUrl": image_url
        }
    
    except Exception as e:
        print(f"Error scraping product {product_url}: {e}")
        return None

def main():
    """
    Main function to scrape products and save to JSON.
    """
    all_products = []
    products_per_category = MAX_PRODUCTS // len(CATEGORIES)
    
    print(f"Starting to scrape {MAX_PRODUCTS} products from {len(CATEGORIES)} categories...")
    
    for category in CATEGORIES:
        print(f"\nScraping category: {category['name']}")
        print(f"Category URL: {category['url']}")
        
        # Get product links from category page
        product_links = get_product_links(category['url'], products_per_category + 10)  # Get extra to filter
        print(f"Found {len(product_links)} product links")
        
        # Scrape each product
        for i, product_url in enumerate(product_links[:products_per_category]):
            print(f"  Scraping product {i+1}/{min(len(product_links), products_per_category)}: {product_url}")
            product = scrape_product(product_url, category['name'])
            
            if product and product['name'] and product['price'] > 0:
                all_products.append(product)
                print(f"    ✓ Successfully scraped: {product['name']}")
            else:
                print(f"    ✗ Failed to scrape or missing data")
            
            # Stop if we've reached the maximum
            if len(all_products) >= MAX_PRODUCTS:
                break
        
        # Stop if we've reached the maximum
        if len(all_products) >= MAX_PRODUCTS:
            break
    
    # Ensure we don't exceed the maximum
    all_products = all_products[:MAX_PRODUCTS]
    
    # Save to JSON file
    print(f"\nSaving {len(all_products)} products to {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(all_products, f, ensure_ascii=False, indent=2)
    
    print(f"✓ Successfully saved {len(all_products)} products to {OUTPUT_FILE}")
    
    # Print summary
    print("\n=== Summary ===")
    category_counts = {}
    for product in all_products:
        cat = product['category']
        category_counts[cat] = category_counts.get(cat, 0) + 1
    
    for category, count in category_counts.items():
        print(f"{category}: {count} products")
    
    print(f"\nTotal: {len(all_products)} products")

if __name__ == "__main__":
    main()
