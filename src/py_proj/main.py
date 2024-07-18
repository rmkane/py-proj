import typer
from rich.console import Console
from rich.table import Table

app = typer.Typer()
console = Console()


@app.command()
def create(name: str):
    console.print(f"Hello, [bold magenta]{name}[/bold magenta]!")


@app.command()
def show_table():
    table = Table(title="Sample Table")
    table.add_column("Name", justify="right", style="cyan", no_wrap=True)
    table.add_column("Age", style="magenta")
    table.add_column("City", style="green")

    table.add_row("Alice", "24", "New York")
    table.add_row("Bob", "30", "San Francisco")
    table.add_row("Charlie", "22", "Los Angeles")

    console.print(table)


def main():
    app()
